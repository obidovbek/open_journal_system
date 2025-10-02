#!/bin/bash
set -euo pipefail

NS="ojs-fstu"
IMG_NAME="ojs-fstu:latest"
IMG_TAR="ojs-fstu.tar"

echo "🧹 Resetting namespace..."
kubectl delete namespace "${NS}" --ignore-not-found
kubectl create namespace "${NS}"

echo "🧹 Resetting PersistentVolumes (claimRef cleanup)..."
# Make PVs attachable again in case they were Released/bound previously
kubectl patch pv ojs-mysql-pv-fstu  -p '{"spec":{"claimRef": null}}' || true
kubectl patch pv ojs-files-pv-fstu  -p '{"spec":{"claimRef": null}}' || true
kubectl patch pv ojs-public-pv-fstu -p '{"spec":{"claimRef": null}}' || true

echo "🗑️  Cleaning old PVCs (if any) in namespace ${NS}..."
kubectl delete pvc --all -n "${NS}" --ignore-not-found || true

# Resolve project root relative to this script (./k8s/overlays/fstu/deploy-ojs.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "🚀 Building OJS image..."
cd "$PROJECT_ROOT/docker"
docker build -t "${IMG_NAME}" .
docker save "${IMG_NAME}" -o "${IMG_TAR}"
echo "📦 Importing image into k3s containerd..."
k3s ctr images import "${IMG_TAR}"

echo "📦 Applying Kubernetes manifests..."
cd "$PROJECT_ROOT/k8s/overlays/fstu"

# (Optional) IngressClass for Traefik if not already present
if [ -f "ingressclass-traefik.yaml" ]; then
  kubectl apply -f ingressclass-traefik.yaml
fi

# PV/PVC + Config + Deployments + Ingress
# Note: namespace is already created above, so namespace.yaml is optional.
[ -f "namespace.yaml" ] && kubectl apply -f namespace.yaml || true
kubectl apply -f ojs-pvc.yaml
kubectl apply -f ojs-configmap.yaml
kubectl apply -f ojs-mysql-deployment.yaml
kubectl apply -f ojs-deployment.yaml
kubectl apply -f ojs-ingress.yaml

echo "⏳ Waiting for MySQL to be ready..."
kubectl rollout status deployment/ojs-mysql-deployment-fstu -n "${NS}"

echo "⏳ Waiting for OJS to be ready..."
kubectl rollout status deployment/ojs-deployment-fstu -n "${NS}" || true

echo "🔎 Pods in ${NS}:"
kubectl get pods -n "${NS}" -o wide

echo "✅ Done. OJS should be available (via ingress) at: https://publications.fstu.uz"

echo ""
echo "# Logs (follow):"
echo "kubectl logs -f deployment/ojs-deployment-fstu -n ${NS}"
echo "kubectl logs -f deployment/ojs-mysql-deployment-fstu -n ${NS}"
echo ""
echo "# Port-forward (local test):"
echo "kubectl port-forward -n ${NS} deploy/ojs-deployment-fstu 8080:80"
