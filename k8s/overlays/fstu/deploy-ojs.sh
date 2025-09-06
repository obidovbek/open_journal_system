#!/bin/bash

# Deploy OJS to FSTU Environment
echo "Deploying OJS to FSTU Environment..."

# Create namespace if it doesn't exist
kubectl create namespace fstu --dry-run=client -o yaml | kubectl apply -f -

# Build OJS image for FSTU
echo "Building OJS image for FSTU..."
cd ../../../docker
docker build -t ojs-fstu:latest .
docker save ojs-fstu:latest -o ojs-fstu.tar

# Load image to k3s (adjust for your k8s setup)
k3s ctr images import ojs-fstu.tar

# Apply OJS configurations
echo "Applying OJS configurations..."
cd ../k8s/overlays/fstu
kubectl apply -f ojs-pvc.yaml
kubectl apply -f ojs-configmap.yaml
kubectl apply -f ojs-mysql-deployment.yaml
kubectl apply -f ojs-deployment.yaml

# Wait for deployments to be ready
echo "Waiting for OJS deployments to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/ojs-mysql-deployment-fstu -n fstu
kubectl wait --for=condition=available --timeout=600s deployment/ojs-deployment-fstu -n fstu

# Get service information
echo "Getting OJS service information..."
kubectl get services -l app=ojs-fstu -n fstu
kubectl get services -l app=ojs-mysql-fstu -n fstu

# Get pod status
echo "Getting OJS pod status..."
kubectl get pods -l app=ojs-fstu -n fstu
kubectl get pods -l app=ojs-mysql-fstu -n fstu

echo "OJS deployment completed!"
echo "OJS will be available at: https://publications.fstu.uz"
echo ""
echo "To check logs:"
echo "kubectl logs -f deployment/ojs-deployment-fstu -n fstu"
echo "kubectl logs -f deployment/ojs-mysql-deployment-fstu -n fstu"
echo ""
echo "Note: You need to update the main FSTU ingress to include publications.fstu.uz routing" 