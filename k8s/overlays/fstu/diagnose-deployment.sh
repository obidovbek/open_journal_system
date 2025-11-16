#!/bin/bash

echo "=== OJS Deployment Diagnostics ==="
echo ""

NAMESPACE="ojs-fstu"

echo "1. Checking pods status..."
echo "----------------------------"
kubectl get pods -n "$NAMESPACE"
echo ""

echo "2. Checking pod details..."
echo "----------------------------"
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app=ojs-fstu -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$POD_NAME" ]; then
    echo "Pod: $POD_NAME"
    echo ""
    kubectl describe pod "$POD_NAME" -n "$NAMESPACE" | tail -50
else
    echo "No OJS pod found"
fi
echo ""

echo "3. Checking pod logs (init containers)..."
echo "-------------------------------------------"
if [ -n "$POD_NAME" ]; then
    echo "=== copy-app-files init container logs ==="
    kubectl logs "$POD_NAME" -n "$NAMESPACE" -c copy-app-files 2>/dev/null || echo "No logs available"
    echo ""
    echo "=== fix-permissions init container logs ==="
    kubectl logs "$POD_NAME" -n "$NAMESPACE" -c fix-permissions 2>/dev/null || echo "No logs available"
    echo ""
    echo "=== main container logs ==="
    kubectl logs "$POD_NAME" -n "$NAMESPACE" -c ojs 2>/dev/null || echo "No logs available"
fi
echo ""

echo "4. Checking PVC status..."
echo "----------------------------"
kubectl get pvc -n "$NAMESPACE"
echo ""

echo "5. Checking PV status..."
echo "----------------------------"
kubectl get pv | grep fstu
echo ""

echo "6. Checking events..."
echo "----------------------------"
kubectl get events -n "$NAMESPACE" --sort-by='.lastTimestamp' | tail -20
echo ""

