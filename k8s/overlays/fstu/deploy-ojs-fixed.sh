#!/bin/bash

# Deploy OJS to FSTU Environment - Fixed Version
echo "🚀 Deploying OJS to FSTU Environment (Fixed Version)..."

# Get the script directory to build paths relative to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
NAMESPACE="ojs-fstu"

# Create namespace if it doesn't exist
echo "📋 Creating namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Clean up any existing problematic PVs if they exist
echo "🧹 Cleaning up any problematic PVs..."
kubectl delete pv ojs-files-pv-fstu ojs-mysql-pv-fstu ojs-public-pv-fstu --ignore-not-found=true

# Build OJS image for FSTU
echo "🔨 Building OJS image for FSTU..."
cd "$PROJECT_ROOT/docker"
docker build -t ojs-fstu:latest .
docker save ojs-fstu:latest -o ojs-fstu.tar

# Load image to k3s (adjust for your k8s setup)
echo "📦 Loading image to k3s..."
k3s ctr images import ojs-fstu.tar

# Apply OJS configurations in the correct order
echo "⚙️  Applying OJS configurations..."
cd "$SCRIPT_DIR"

# Apply configmap and secrets first
kubectl apply -f ojs-configmap.yaml

# Apply fixed PVCs (using dynamic provisioning)
kubectl apply -f ojs-pvc-fixed.yaml

# Wait for PVCs to be bound
echo "⏳ Waiting for PVCs to bind..."
kubectl wait --for=condition=Bound pvc --all -n $NAMESPACE --timeout=60s || {
    echo "⚠️  PVCs didn't bind within 60s, checking status..."
    kubectl get pvc -n $NAMESPACE
}

# Apply MySQL deployment
kubectl apply -f ojs-mysql-deployment.yaml

# Apply fixed OJS deployment (with init container for permissions)
kubectl apply -f ojs-deployment-fixed.yaml

# Apply ingress
kubectl apply -f ojs-ingress.yaml

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available deployment/ojs-deployment-fstu -n $NAMESPACE --timeout=300s
kubectl wait --for=condition=available deployment/ojs-mysql-deployment-fstu -n $NAMESPACE --timeout=300s

# Check final status
echo ""
echo "📊 Deployment Status:"
kubectl get pods -n $NAMESPACE
echo ""
kubectl get pvc -n $NAMESPACE
echo ""
kubectl get svc -n $NAMESPACE

echo ""
echo "✅ OJS deployment completed!"
echo "🌐 OJS will be available at: https://publications.fstu.uz"
echo ""
echo "📋 Useful commands:"
echo "   Check OJS logs: kubectl logs -f deployment/ojs-deployment-fstu -n $NAMESPACE"
echo "   Check MySQL logs: kubectl logs -f deployment/ojs-mysql-deployment-fstu -n $NAMESPACE"
echo "   Check pod status: kubectl get pods -n $NAMESPACE"
echo ""
echo "🔧 If you need to redeploy, use this script instead of the old deploy-ojs.sh" 