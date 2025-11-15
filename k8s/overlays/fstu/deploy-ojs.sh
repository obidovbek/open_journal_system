#!/bin/bash

# Deploy OJS to FSTU Environment
echo "Deploying OJS to FSTU Environment..."

# Create namespace if it doesn't exist
kubectl create namespace ojs-fstu --dry-run=client -o yaml | kubectl apply -f -

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