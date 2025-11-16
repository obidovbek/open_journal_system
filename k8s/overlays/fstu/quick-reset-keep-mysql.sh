#!/bin/bash

set -e

echo "=========================================="
echo "  QUICK RESET (Keep MySQL Data)"
echo "=========================================="
echo ""
echo "This will reset OJS but KEEP your MySQL database"
echo ""

NAMESPACE="ojs-fstu"

echo ""
echo "Step 1: Deleting OJS deployment..."
echo "-----------------------------------"
kubectl delete deployment ojs-deployment-fstu -n "$NAMESPACE" --ignore-not-found=true --wait=true

echo ""
echo "Step 2: Deleting OJS PVCs (keeping MySQL)..."
echo "--------------------------------------------"
kubectl delete pvc ojs-app-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true
kubectl delete pvc ojs-files-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true
kubectl delete pvc ojs-public-fstu-pvc -n "$NAMESPACE" --ignore-not-found=true --wait=true

echo ""
echo "Step 3: Deleting OJS PVs (keeping MySQL)..."
echo "-------------------------------------------"
kubectl delete pv ojs-app-pv-fstu --ignore-not-found=true --wait=true
kubectl delete pv ojs-files-pv-fstu --ignore-not-found=true --wait=true
kubectl delete pv ojs-public-pv-fstu --ignore-not-found=true --wait=true

echo "Waiting for cleanup..."
sleep 5

echo ""
echo "Step 4: Running deployment..."
echo "-----------------------------"
cd "$(dirname "$0")"
./deploy-ojs.sh

echo ""
echo "=========================================="
echo "  RESET COMPLETE!"
echo "=========================================="
echo ""
echo "MySQL database preserved."
echo "OJS files reset to defaults."
echo ""

