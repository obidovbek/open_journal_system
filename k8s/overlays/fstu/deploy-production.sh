#!/bin/bash

# OJS FSTU Production Deployment Script
# This script deploys OJS to Kubernetes with proper database configuration

set -e

echo "======================================"
echo "OJS FSTU Production Deployment"
echo "======================================"
echo ""

# Check if we're in the correct directory
if [ ! -f "namespace.yaml" ]; then
    echo "Error: Please run this script from the k8s/overlays/fstu directory"
    exit 1
fi

# Step 1: Build the Kubernetes-specific Docker image
echo "Step 1: Building Kubernetes-specific OJS image..."
cd ../../../
docker build -f docker/Dockerfile.k8s -t ojs-fstu:k8s ./docker/
echo "✓ Image built successfully"
echo ""

# Step 2: Create namespace
echo "Step 2: Creating namespace..."
cd k8s/overlays/fstu
kubectl apply -f namespace.yaml
echo "✓ Namespace created"
echo ""

# Step 3: Apply PVCs
echo "Step 3: Creating Persistent Volume Claims..."
if [ -f "ojs-pvc-fixed.yaml" ]; then
    kubectl apply -f ojs-pvc-fixed.yaml
elif [ -f "ojs-pvc.yaml" ]; then
    kubectl apply -f ojs-pvc.yaml
else
    echo "Warning: No PVC file found, skipping..."
fi
echo "✓ PVCs created"
echo ""

# Step 4: Apply ConfigMap and Secrets
echo "Step 4: Applying ConfigMap and Secrets..."
kubectl apply -f ojs-configmap-production.yaml
echo "✓ ConfigMap and Secrets applied"
echo ""

# Step 5: Deploy MySQL
echo "Step 5: Deploying MySQL database..."
kubectl apply -f ojs-mysql-deployment.yaml
echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=ojs-mysql-fstu -n ojs-fstu --timeout=300s
echo "✓ MySQL is ready"
echo ""

# Step 6: Deploy OJS
echo "Step 6: Deploying OJS application..."
kubectl apply -f ojs-deployment-production.yaml
echo "Waiting for OJS to be ready..."
kubectl wait --for=condition=ready pod -l app=ojs-fstu -n ojs-fstu --timeout=300s
echo "✓ OJS is ready"
echo ""

# Step 7: Apply Ingress
echo "Step 7: Applying Ingress..."
if [ -f "ojs-ingress.yaml" ]; then
    kubectl apply -f ojs-ingress.yaml
    echo "✓ Ingress applied"
else
    echo "Warning: No ingress file found, skipping..."
fi
echo ""

# Step 8: Display deployment status
echo "======================================"
echo "Deployment Status"
echo "======================================"
echo ""
echo "Pods:"
kubectl get pods -n ojs-fstu
echo ""
echo "Services:"
kubectl get svc -n ojs-fstu
echo ""
echo "Ingress:"
kubectl get ingress -n ojs-fstu
echo ""

# Step 9: Display logs
echo "======================================"
echo "Recent OJS Logs"
echo "======================================"
kubectl logs -l app=ojs-fstu -n ojs-fstu --tail=20
echo ""

# Step 10: Display next steps
echo "======================================"
echo "✓ Deployment Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Verify database connectivity:"
echo "   kubectl logs -l app=ojs-fstu -n ojs-fstu"
echo ""
echo "2. Access OJS installation:"
echo "   https://publications.fstu.uz/index/install/install"
echo ""
echo "3. Monitor pods:"
echo "   kubectl get pods -n ojs-fstu -w"
echo ""
echo "4. Check pod details:"
echo "   kubectl describe pod -l app=ojs-fstu -n ojs-fstu"
echo ""
echo "5. Connect to database (if needed):"
echo "   kubectl exec -it deployment/ojs-mysql-deployment-fstu -n ojs-fstu -- mysql -u ojs2 -p ojs2"
echo ""
echo "Troubleshooting:"
echo "- View OJS logs: kubectl logs -l app=ojs-fstu -n ojs-fstu -f"
echo "- View MySQL logs: kubectl logs -l app=ojs-mysql-fstu -n ojs-fstu -f"
echo "- Shell into OJS: kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- sh"
echo ""

