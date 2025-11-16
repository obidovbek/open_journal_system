#!/bin/bash

# Deploy OJS to FSTU Environment
echo "Deploying OJS to FSTU Environment..."

# Create namespace if it doesn't exist
kubectl create namespace ojs-fstu --dry-run=client -o yaml | kubectl apply -f -

# Get absolute path to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
OJS_APP_VOLUME="$PROJECT_ROOT/data/ojs-app"

# Create directory for OJS app volume if it doesn't exist
echo "📁 Ensuring OJS app volume directory exists..."
mkdir -p "$OJS_APP_VOLUME"
chmod 755 "$OJS_APP_VOLUME"

# Check if volume is empty and pre-populate it from Docker image
FILE_COUNT=$(ls -A "$OJS_APP_VOLUME" 2>/dev/null | wc -l)
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
        echo "Copying files from container to $OJS_APP_VOLUME..."
        docker cp "$TEMP_CONTAINER:/var/www/html/." "$OJS_APP_VOLUME/"
        docker rm "$TEMP_CONTAINER" > /dev/null
        mkdir -p "$OJS_APP_VOLUME/public"
        chown -R 100:101 "$OJS_APP_VOLUME"
        chmod -R 755 "$OJS_APP_VOLUME"
        echo "✅ Files extracted successfully!"
        echo "📊 Volume now contains: $(ls -A "$OJS_APP_VOLUME" | wc -l) items"
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



echo ""
echo "✅ OJS deployment completed!"
echo "🌐 OJS will be available at: https://publications.fstu.uz"
echo ""
echo "📂 OJS files location: $OJS_APP_VOLUME"
echo "   You can edit files directly in this directory!"
echo ""
echo "📋 Useful commands:"
echo "   Check OJS logs: kubectl logs -f deployment/ojs-deployment-fstu -n ojs-fstu"
echo "   Check MySQL logs: kubectl logs -f deployment/ojs-mysql-deployment-fstu -n ojs-fstu"
echo "   Edit OJS files: cd $OJS_APP_VOLUME"
echo ""
echo "Note: You need to update the main FSTU ingress to include publications.fstu.uz routing" 