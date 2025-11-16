#!/bin/bash

# Quick fix script to delete old PV and recreate with new path
NAMESPACE="ojs-fstu"

echo "🔧 Fixing PersistentVolume path..."
echo ""

# Check if old PV exists
if kubectl get pv ojs-app-pv-fstu &>/dev/null; then
    echo "📋 Found existing PV, checking path..."
    OLD_PATH=$(kubectl get pv ojs-app-pv-fstu -o jsonpath='{.spec.hostPath.path}')
    echo "Current path: $OLD_PATH"
    echo ""
    
    NEW_PATH="/home/fstu/projects/open_journal_system/data/ojs-app"
    
    if [ "$OLD_PATH" != "$NEW_PATH" ]; then
        echo "⚠️  Path mismatch detected!"
        echo "Old: $OLD_PATH"
        echo "New: $NEW_PATH"
        echo ""
        echo "🗑️  Deleting old PV and PVC..."
        
        # Delete PVC first (it references the PV)
        kubectl delete pvc ojs-app-fstu-pvc -n $NAMESPACE --ignore-not-found=true
        
        # Delete PV
        kubectl delete pv ojs-app-pv-fstu --ignore-not-found=true
        
        echo "⏳ Waiting for deletion to complete..."
        sleep 3
        
        echo "✅ Old PV/PVC deleted"
        echo ""
        echo "📋 Now run deploy script again:"
        echo "   ./k8s/overlays/fstu/deploy-ojs.sh"
    else
        echo "✅ PV path is already correct: $NEW_PATH"
    fi
else
    echo "✅ No existing PV found, ready to create new one"
fi

