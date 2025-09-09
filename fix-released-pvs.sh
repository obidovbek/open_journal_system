#!/bin/bash

# Fix Released PVs for OJS FSTU
echo "🔧 Fixing Released Persistent Volumes"
echo "====================================="

NAMESPACE="ojs-fstu"

# Step 1: Delete the current PVCs that are stuck in Pending
echo "🧹 Deleting pending PVCs..."
kubectl delete pvc ojs-files-fstu-pvc ojs-mysql-fstu-pvc ojs-public-fstu-pvc -n $NAMESPACE

# Step 2: Delete the Released PVs so we can recreate them
echo "🗑️  Deleting released PVs..."
kubectl delete pv ojs-files-pv-fstu ojs-mysql-pv-fstu ojs-public-pv-fstu

# Step 3: Wait a moment for cleanup
echo "⏳ Waiting for cleanup..."
sleep 5

# Step 4: Recreate the PVs and PVCs
echo "🔄 Recreating PVs and PVCs..."
kubectl apply -f k8s/overlays/fstu/ojs-pvc.yaml

# Step 5: Wait for PVCs to bind
echo "⏳ Waiting for PVCs to bind..."
sleep 10

# Step 6: Check PV and PVC status
echo "📊 Checking PV status:"
kubectl get pv | grep fstu

echo ""
echo "📊 Checking PVC status:"
kubectl get pvc -n $NAMESPACE

echo ""
echo "🚀 Now restart the deployments:"
echo "kubectl rollout restart deployment ojs-deployment-fstu -n $NAMESPACE"
echo "kubectl rollout restart deployment ojs-mysql-deployment-fstu -n $NAMESPACE" 