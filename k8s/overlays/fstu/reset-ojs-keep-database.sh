#!/bin/bash

set -e

echo "=========================================="
echo "  RESET OJS - KEEP EXISTING DATABASE"
echo "=========================================="
echo ""
echo "This will:"
echo "  ✓ KEEP your existing MySQL database"
echo "  ✓ KEEP your existing OJS files"
echo "  ✓ Reset only the OJS deployment"
echo "  ✓ Add guest submission files"
echo ""
echo "Your data locations:"
echo "  - MySQL: /opt/local-path-provisioner/ojs-mysql-data-fstu"
echo "  - Files: /opt/local-path-provisioner/ojs-files-data-fstu"
echo "  - Public: /opt/local-path-provisioner/ojs-public-data-fstu"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

NAMESPACE="ojs-fstu"

echo ""
echo "Step 1: Checking existing data directories..."
echo "---------------------------------------------"
if [ -d "/opt/local-path-provisioner/ojs-mysql-data-fstu" ]; then
    echo "✓ MySQL data found: /opt/local-path-provisioner/ojs-mysql-data-fstu"
    ls -lh /opt/local-path-provisioner/ojs-mysql-data-fstu | head -5
else
    echo "⚠ MySQL data directory not found!"
fi

if [ -d "/opt/local-path-provisioner/ojs-files-data-fstu" ]; then
    echo "✓ OJS files found: /opt/local-path-provisioner/ojs-files-data-fstu"
else
    echo "⚠ OJS files directory not found!"
fi

if [ -d "/opt/local-path-provisioner/ojs-public-data-fstu" ]; then
    echo "✓ OJS public files found: /opt/local-path-provisioner/ojs-public-data-fstu"
else
    echo "⚠ OJS public directory not found!"
fi

echo ""
echo "Step 2: Deleting OJS deployment only..."
echo "---------------------------------------"
kubectl delete deployment ojs-deployment-fstu -n "$NAMESPACE" --ignore-not-found=true --wait=true

echo "Waiting for pod to terminate..."
sleep 10

echo ""
echo "Step 3: Deleting and recreating OJS app PVC/PV..."
echo "-------------------------------------------------"
kubectl delete pvc ojs-app-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true
kubectl delete pv ojs-app-pv-fstu --ignore-not-found=true --wait=true

echo "Waiting for cleanup..."
sleep 5

echo ""
echo "Step 4: Verifying MySQL and Files PVCs are still bound..."
echo "---------------------------------------------------------"
kubectl get pvc -n "$NAMESPACE"

echo ""
echo "Step 5: Running deployment..."
echo "-----------------------------"
cd "$(dirname "$0")"
./deploy-ojs.sh

echo ""
echo "=========================================="
echo "  DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "Your existing data has been preserved:"
echo "  ✓ MySQL database"
echo "  ✓ OJS uploaded files"
echo "  ✓ OJS public files"
echo ""
echo "OJS should now be accessible at:"
echo "  https://publications.fstu.uz/itj"
echo ""
echo "Guest submission form at:"
echo "  https://publications.fstu.uz/itj/public/guest-submission.html"
echo ""

