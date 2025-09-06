#!/bin/bash

echo "=== Quick Fix: Rebuilding and Redeploying OJS ==="

# Build the simplified Docker image
echo "1. Building Docker image..."
cd docker
docker build -t ojs-fstu:latest .
cd ..

# Save and import to k3s if available
echo "2. Importing to k3s..."
docker save ojs-fstu:latest -o ojs-fstu.tar
if command -v k3s &> /dev/null; then
    k3s ctr images import ojs-fstu.tar
fi
rm -f ojs-fstu.tar

# Restart the deployment
echo "3. Restarting OJS deployment..."
kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu

# Wait for the new pod to be ready
echo "4. Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ojs-deployment-fstu -n ojs-fstu

# Check status
echo "5. Checking status..."
kubectl get pods -n ojs-fstu

echo ""
echo "=== Fix Complete ==="
echo "Check the logs with: kubectl logs -f deployment/ojs-deployment-fstu -n ojs-fstu"
echo "Visit: https://publications.fstu.uz" 