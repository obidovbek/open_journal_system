#!/bin/bash

# Deploy OJS to FSTU Environment
echo "Deploying OJS to FSTU Environment..."

# Create namespace if it doesn't exist
kubectl create namespace ojs-fstu --dry-run=client -o yaml | kubectl apply -f -

# Create directory for OJS app volume if it doesn't exist
echo "📁 Ensuring OJS app volume directory exists..."
mkdir -p /opt/local-path-provisioner/ojs-app-data-fstu
chmod 755 /opt/local-path-provisioner/ojs-app-data-fstu

# Check if volume is empty and pre-populate it from Docker image
FILE_COUNT=$(ls -A /opt/local-path-provisioner/ojs-app-data-fstu 2>/dev/null | wc -l)
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "📦 Volume is empty, extracting OJS files from Docker image..."
    # We'll build the image first, then extract files
    EXTRACT_FILES=true
else
    echo "✅ Volume already contains $FILE_COUNT files, skipping extraction"
    EXTRACT_FILES=false
fi

# Build OJS image for FSTU
echo "Building OJS image for FSTU..."
# Get the script directory to build paths relative to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

cd "$PROJECT_ROOT/docker"
docker build -t ojs-fstu:latest .
docker save ojs-fstu:latest -o ojs-fstu.tar

# Load image to k3s (adjust for your k8s setup)
k3s ctr images import ojs-fstu.tar

# Extract files from image to volume if needed
if [ "$EXTRACT_FILES" = true ]; then
    echo "📋 Extracting OJS files from image to volume..."
    TEMP_CONTAINER=$(docker create ojs-fstu:latest)
    if [ -n "$TEMP_CONTAINER" ]; then
        echo "Copying files from container to /opt/local-path-provisioner/ojs-app-data-fstu..."
        docker cp "$TEMP_CONTAINER:/var/www/html/." /opt/local-path-provisioner/ojs-app-data-fstu/
        docker rm "$TEMP_CONTAINER" > /dev/null
        mkdir -p /opt/local-path-provisioner/ojs-app-data-fstu/public
        chown -R 100:101 /opt/local-path-provisioner/ojs-app-data-fstu
        chmod -R 755 /opt/local-path-provisioner/ojs-app-data-fstu
        echo "✅ Files extracted successfully!"
        echo "📊 Volume now contains: $(ls -A /opt/local-path-provisioner/ojs-app-data-fstu | wc -l) items"
    else
        echo "⚠️  Failed to create temporary container, init container will handle file copy"
    fi
fi

# Apply OJS configurations
echo "Applying OJS configurations..."
cd "$PROJECT_ROOT/k8s/overlays/fstu"
kubectl apply -f ojs-pvc.yaml
kubectl apply -f ojs-configmap.yaml
kubectl apply -f ojs-mysql-deployment.yaml
kubectl apply -f ojs-deployment.yaml
kubectl apply -f ojs-ingress.yaml



echo "OJS deployment completed!"
echo "OJS will be available at: https://publications.fstu.uz"
echo ""
echo "To check logs:"
echo "kubectl logs -f deployment/ojs-deployment-fstu -n ojs-fstu"
echo "kubectl logs -f deployment/ojs-mysql-deployment-fstu -n ojs-fstu"
echo ""
echo "Note: You need to update the main FSTU ingress to include publications.fstu.uz routing" 