#!/bin/bash

set -e

echo "Deploying OJS to FSTU Environment..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
OJS_APP_VOLUME="$PROJECT_ROOT/data/ojs-app"
LOCAL_PUBLIC_DIR="$OJS_APP_VOLUME/public"
NAMESPACE="ojs-fstu"

ensure_namespace() {
    echo "Ensuring namespace $NAMESPACE exists..."
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
}

prepare_local_volume() {
    echo "Ensuring OJS app volume directory exists..."
    mkdir -p "$OJS_APP_VOLUME"
    chmod 755 "$OJS_APP_VOLUME"
}

populate_local_volume_if_empty() {
    local count
    count=$(ls -A "$OJS_APP_VOLUME" 2>/dev/null | wc -l || true)
    if [ "$count" -eq 0 ]; then
        echo "Local OJS app directory is empty, extracting from Docker image..."
        EXTRACT_FILES=true
    else
        echo "Local OJS app directory already contains $count items, skipping extraction."
        EXTRACT_FILES=false
    fi

    if [ "$EXTRACT_FILES" = true ]; then
        TEMP_CONTAINER=$(docker create ojs-fstu:latest)
        if [ -n "$TEMP_CONTAINER" ]; then
            echo "Copying files from container to $OJS_APP_VOLUME..."
            docker cp "$TEMP_CONTAINER:/var/www/html/." "$OJS_APP_VOLUME/"
            docker rm "$TEMP_CONTAINER" >/dev/null
            mkdir -p "$OJS_APP_VOLUME/public"
            chown -R 100:101 "$OJS_APP_VOLUME"
            chmod -R 755 "$OJS_APP_VOLUME"
            echo "Files extracted successfully."
        else
            echo "Failed to create temporary container; init container will copy files instead."
        fi
    fi
}

build_and_load_image() {
    echo "Building OJS image for FSTU..."
    cd "$PROJECT_ROOT/docker"
    docker build -t ojs-fstu:latest .
    docker save ojs-fstu:latest -o ojs-fstu.tar
    echo "Loading image into k3s..."
    k3s ctr images import ojs-fstu.tar
}

apply_manifests() {
    echo "Applying Kubernetes manifests..."
    cd "$PROJECT_ROOT/k8s/overlays/fstu"
    kubectl apply -f ojs-pvc.yaml
    kubectl apply -f ojs-configmap.yaml
    kubectl apply -f ojs-mysql-deployment.yaml
    kubectl apply -f ojs-deployment.yaml
    kubectl apply -f ojs-ingress.yaml
}

wait_for_deployments() {
    echo "Waiting for deployments to become ready..."
    kubectl rollout status deployment/ojs-deployment-fstu -n "$NAMESPACE" --timeout=300s
    kubectl rollout status deployment/ojs-mysql-deployment-fstu -n "$NAMESPACE" --timeout=300s
}

sync_public_files() {
    if [ ! -d "$LOCAL_PUBLIC_DIR" ]; then
        echo "Local public directory not found at $LOCAL_PUBLIC_DIR, skipping sync."
        return
    fi

    if [ -z "$(ls -A "$LOCAL_PUBLIC_DIR")" ]; then
        echo "Local public directory is empty, skipping sync."
        return
    fi

    local pod_name
    pod_name=$(kubectl get pods -n "$NAMESPACE" -l app=ojs-fstu -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)

    if [ -z "$pod_name" ]; then
        echo "Could not find a running OJS pod; skipping public directory sync."
        return
    fi

    echo "Syncing local public directory to pod $pod_name..."
    kubectl cp "$LOCAL_PUBLIC_DIR/." "$pod_name:/var/www/html/public" -n "$NAMESPACE"
    kubectl exec -n "$NAMESPACE" "$pod_name" -- chown -R 100:101 /var/www/html/public
    kubectl exec -n "$NAMESPACE" "$pod_name" -- find /var/www/html/public -type f -exec chmod 644 {} \;
    echo "Public directory synced successfully."
}

ensure_namespace
prepare_local_volume
build_and_load_image
populate_local_volume_if_empty
apply_manifests
wait_for_deployments
sync_public_files

echo ""
echo "Deployment completed!"
echo "OJS will be available at: https://publications.fstu.uz"
echo ""
echo "Local OJS files location: $OJS_APP_VOLUME"
echo "You can edit files directly in this directory."
echo ""
echo "Useful commands:"
echo "  kubectl logs -f deployment/ojs-deployment-fstu -n $NAMESPACE"
echo "  kubectl logs -f deployment/ojs-mysql-deployment-fstu -n $NAMESPACE"
echo "  kubectl get pods -n $NAMESPACE"
echo ""
echo "Note: Update the main FSTU ingress to include publications.fstu.uz routing if needed."
