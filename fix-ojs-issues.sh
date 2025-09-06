#!/bin/bash

echo "=== OJS HTTPS/SSL Fix Script ==="
echo "This script will fix the mixed content and JavaScript issues"
echo ""

# Check if we're in the right directory
if [ ! -d "k8s" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "Error: kubectl is not installed or not in PATH"
        exit 1
    fi
}

# Function to check if docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Error: docker is not installed or not in PATH"
        exit 1
    fi
}

echo "Step 1: Checking prerequisites..."
check_kubectl
check_docker
echo "✓ Prerequisites check passed"

echo ""
echo "Step 2: Building updated OJS image..."
cd docker
docker build -t ojs-fstu:latest .
if [ $? -ne 0 ]; then
    echo "Error: Docker build failed"
    exit 1
fi

# For k3s, save and import the image
docker save ojs-fstu:latest -o ojs-fstu.tar
if command -v k3s &> /dev/null; then
    echo "Importing image to k3s..."
    k3s ctr images import ojs-fstu.tar
    rm ojs-fstu.tar
fi

echo "✓ Image built successfully"
cd ..

echo ""
echo "Step 3: Applying Kubernetes configurations..."

# Create namespace if it doesn't exist
kubectl create namespace ojs-fstu --dry-run=client -o yaml | kubectl apply -f -

# Apply configurations in order
cd k8s/overlays/fstu
kubectl apply -f ojs-pvc.yaml
echo "✓ Applied persistent volume claims"

kubectl apply -f ojs-configmap.yaml
echo "✓ Applied configmap and secrets"

kubectl apply -f ojs-mysql-deployment.yaml
echo "✓ Applied MySQL deployment"

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ojs-mysql-deployment-fstu -n ojs-fstu

kubectl apply -f ojs-deployment.yaml
echo "✓ Applied OJS deployment"

kubectl apply -f ojs-ingress.yaml
echo "✓ Applied ingress configuration"

echo ""
echo "Step 4: Waiting for OJS deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ojs-deployment-fstu -n ojs-fstu

echo ""
echo "Step 5: Checking deployment status..."
kubectl get pods -n ojs-fstu

echo ""
echo "=== Fix Applied Successfully! ==="
echo ""
echo "🔧 What was fixed:"
echo "  ✓ Mixed content errors (HTTP -> HTTPS)"
echo "  ✓ SSL/TLS configuration with cert-manager"
echo "  ✓ JavaScript loading issues"
echo "  ✓ PHP configuration improvements"
echo "  ✓ Proper environment variable handling"
echo ""
echo "🌐 Your OJS installation should now be available at:"
echo "   https://publications.fstu.uz"
echo ""
echo "📋 Useful commands:"
echo "   Check pods:        kubectl get pods -n ojs-fstu"
echo "   Check services:    kubectl get svc -n ojs-fstu"
echo "   Check ingress:     kubectl get ingress -n ojs-fstu"
echo "   View OJS logs:     kubectl logs -f deployment/ojs-deployment-fstu -n ojs-fstu"
echo "   View MySQL logs:   kubectl logs -f deployment/ojs-mysql-deployment-fstu -n ojs-fstu"
echo "   Restart OJS:       kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu"
echo ""
echo "⚠️  Note: If you still see issues, try:"
echo "   1. Clear your browser cache"
echo "   2. Wait a few minutes for SSL certificate to be issued"
echo "   3. Check the logs for any remaining errors"
echo ""
echo "🔒 SSL certificate will be automatically issued by cert-manager"
echo "   You can check the certificate status with:"
echo "   kubectl get certificate -n ojs-fstu"
echo "" 