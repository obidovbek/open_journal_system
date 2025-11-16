#!/bin/bash

set -e

echo "=== Fixing OJS Deployment Issues ==="
echo ""

NAMESPACE="ojs-fstu"

echo "Step 1: Deleting problematic PVC and PV..."
echo "-------------------------------------------"

# Delete the ojs-app PVC and PV
kubectl delete pvc ojs-app-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true
kubectl delete pv ojs-app-pv-fstu --ignore-not-found=true --wait=true

echo "Waiting for resources to be fully deleted..."
sleep 5

echo ""
echo "Step 2: Deleting the deployment to ensure clean state..."
echo "---------------------------------------------------------"

kubectl delete deployment ojs-deployment-fstu -n "$NAMESPACE" --ignore-not-found=true --wait=true

echo "Waiting for pods to terminate..."
sleep 10

echo ""
echo "Step 3: Running the deployment script..."
echo "-----------------------------------------"

cd "$(dirname "$0")"
./deploy-ojs.sh

echo ""
echo "=== Fix Complete ==="
echo ""
echo "The deployment should now work correctly."
echo ""

