# Quick Fix for OJS Deployment Issue

## Problem

The PersistentVolume path is immutable and cannot be changed after creation. The error shows:
```
spec.persistentvolumesource is immutable after creation
```

## Solution: Delete and Recreate

Run these commands in order:

### Step 1: Delete the problematic PVC and PV

```bash
# Delete the ojs-app PVC
kubectl delete pvc ojs-app-fstu-pvc -n ojs-fstu --wait=true

# Delete the ojs-app PV
kubectl delete pv ojs-app-pv-fstu --wait=true

# Wait for deletion to complete
sleep 5
```

### Step 2: Delete the deployment

```bash
# Delete the deployment to ensure clean state
kubectl delete deployment ojs-deployment-fstu -n ojs-fstu --wait=true

# Wait for pods to terminate
sleep 10
```

### Step 3: Run the deployment script

```bash
cd /home/fstu/projects/open_journal_system
chmod +x ./k8s/overlays/fstu/deploy-ojs.sh
./k8s/overlays/fstu/deploy-ojs.sh
```

## One-Command Fix

Or use the automated fix script:

```bash
cd /home/fstu/projects/open_journal_system
chmod +x ./k8s/overlays/fstu/fix-and-redeploy.sh
./k8s/overlays/fstu/fix-and-redeploy.sh
```

## What This Does

1. Deletes the old PersistentVolume with the wrong path
2. Deletes the old PersistentVolumeClaim
3. Deletes the deployment
4. Runs the deployment script which will:
   - Create new PV with correct path (`/home/fstu/projects/open_journal_system/data/ojs-app`)
   - Create new PVC
   - Deploy OJS
   - Sync guest submission files

## After Deployment

Verify the files are there:

```bash
# Get pod name
POD_NAME=$(kubectl get pods -n ojs-fstu -l app=ojs-fstu -o jsonpath='{.items[0].metadata.name}')

# Check files
kubectl exec -n ojs-fstu $POD_NAME -- ls -la /var/www/html/public/ | grep guest-submission
```

## If Files Still Missing

If the automatic sync doesn't work, manually copy:

```bash
cd /home/fstu/projects/open_journal_system/k8s/overlays/fstu
./sync-guest-submission-files.sh
```

