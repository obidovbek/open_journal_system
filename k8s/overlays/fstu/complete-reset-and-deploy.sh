#!/bin/bash

set -e

echo "=========================================="
echo "  COMPLETE OJS RESET AND FRESH DEPLOY"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will DELETE ALL DATA including:"
echo "   - MySQL database"
echo "   - OJS files"
echo "   - OJS public files"
echo "   - All configurations"
echo ""
read -p "Are you sure you want to continue? Type 'YES' to confirm: " -r
echo
if [[ ! $REPLY == "YES" ]]; then
    echo "Cancelled."
    exit 0
fi

NAMESPACE="ojs-fstu"

echo ""
echo "Step 1: Deleting all deployments..."
echo "-----------------------------------"
kubectl delete deployment ojs-deployment-fstu -n "$NAMESPACE" --ignore-not-found=true --wait=true
kubectl delete deployment ojs-mysql-deployment-fstu -n "$NAMESPACE" --ignore-not-found=true --wait=true

echo "Waiting for pods to terminate..."
sleep 10

echo ""
echo "Step 2: Deleting all services..."
echo "--------------------------------"
kubectl delete service ojs-service-fstu -n "$NAMESPACE" --ignore-not-found=true
kubectl delete service ojs-mysql-service-fstu -n "$NAMESPACE" --ignore-not-found=true

echo ""
echo "Step 3: Deleting all PVCs..."
echo "----------------------------"
kubectl delete pvc ojs-app-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true
kubectl delete pvc ojs-files-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true
kubectl delete pvc ojs-public-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true
kubectl delete pvc ojs-mysql-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true

echo "Waiting for PVCs to be deleted..."
sleep 5

echo ""
echo "Step 4: Deleting all PVs..."
echo "---------------------------"
kubectl delete pv ojs-app-pv-fstu --ignore-not-found=true --wait=true
kubectl delete pv ojs-files-pv-fstu --ignore-not-found=true --wait=true
kubectl delete pv ojs-public-pv-fstu --ignore-not-found=true --wait=true
kubectl delete pv ojs-mysql-pv-fstu --ignore-not-found=true --wait=true

echo "Waiting for PVs to be deleted..."
sleep 5

echo ""
echo "Step 5: Deleting ConfigMaps and Secrets..."
echo "------------------------------------------"
kubectl delete configmap ojs-fstu-config -n "$NAMESPACE" --ignore-not-found=true
kubectl delete secret ojs-fstu-secret -n "$NAMESPACE" --ignore-not-found=true

echo ""
echo "Step 6: Deleting Ingress..."
echo "---------------------------"
kubectl delete ingress ojs-fstu-ingress -n "$NAMESPACE" --ignore-not-found=true

echo ""
echo "Step 7: Cleaning up local data directories..."
echo "---------------------------------------------"
echo "⚠️  This will delete all local data!"
read -p "Delete local data directories? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf /opt/local-path-provisioner/ojs-mysql-data-fstu
    sudo rm -rf /opt/local-path-provisioner/ojs-files-data-fstu
    sudo rm -rf /opt/local-path-provisioner/ojs-public-data-fstu
    sudo rm -rf /opt/local-path-provisioner/ojs-app-data-fstu
    echo "Local data directories deleted."
else
    echo "Keeping local data directories."
fi

echo ""
echo "Step 8: Optionally delete namespace..."
echo "--------------------------------------"
read -p "Delete and recreate namespace? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete namespace "$NAMESPACE" --ignore-not-found=true --wait=true
    echo "Waiting for namespace to be fully deleted..."
    sleep 10
    kubectl create namespace "$NAMESPACE"
    echo "Namespace recreated."
fi

echo ""
echo "Step 9: Waiting for cleanup to complete..."
echo "------------------------------------------"
sleep 5

echo ""
echo "=========================================="
echo "  CLEANUP COMPLETE - STARTING DEPLOYMENT"
echo "=========================================="
echo ""

# Run the deployment script
cd "$(dirname "$0")"
./deploy-ojs.sh

echo ""
echo "=========================================="
echo "  DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Access OJS at: https://publications.fstu.uz/itj"
echo "2. Run the OJS installation wizard"
echo "3. Configure your journal"
echo "4. Test the guest submission form at:"
echo "   https://publications.fstu.uz/itj/public/guest-submission.html"
echo ""

