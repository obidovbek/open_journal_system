#!/bin/bash

# Alternative: Manually clear PV claim references
echo "🔧 Manually clearing PV claim references"
echo "========================================"

NAMESPACE="ojs-fstu"

# Step 1: Delete the pending PVCs first
echo "🧹 Deleting pending PVCs..."
kubectl delete pvc ojs-files-fstu-pvc ojs-mysql-fstu-pvc ojs-public-fstu-pvc -n $NAMESPACE

# Step 2: Clear the claimRef from each PV to make them Available again
echo "🔄 Clearing claimRef from PVs..."

# Clear ojs-files-pv-fstu
kubectl patch pv ojs-files-pv-fstu -p '{"spec":{"claimRef":null}}'

# Clear ojs-mysql-pv-fstu  
kubectl patch pv ojs-mysql-pv-fstu -p '{"spec":{"claimRef":null}}'

# Clear ojs-public-pv-fstu
kubectl patch pv ojs-public-pv-fstu -p '{"spec":{"claimRef":null}}'

echo "⏳ Waiting for PVs to become Available..."
sleep 5

# Step 3: Check PV status
echo "📊 Checking PV status:"
kubectl get pv | grep fstu

# Step 4: Recreate PVCs
echo "🔄 Recreating PVCs..."
kubectl apply -f k8s/overlays/fstu/ojs-pvc.yaml

echo "⏳ Waiting for PVCs to bind..."
sleep 10

echo "📊 Checking PVC status:"
kubectl get pvc -n $NAMESPACE

echo ""
echo "🚀 If PVCs are now Bound, restart the deployments:"
echo "kubectl rollout restart deployment ojs-deployment-fstu -n $NAMESPACE"
echo "kubectl rollout restart deployment ojs-mysql-deployment-fstu -n $NAMESPACE" 