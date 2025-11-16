#!/bin/bash

# Manual script to copy OJS files from image to volume
# Use this if the init container didn't copy files properly

NAMESPACE="ojs-fstu"
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=ojs-fstu -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "❌ No OJS pod found in namespace $NAMESPACE"
    echo "Please deploy OJS first using deploy-ojs.sh"
    exit 1
fi

echo "📋 Found pod: $POD_NAME"
echo "📁 Copying OJS files from image to volume..."

# Create a temporary job to copy files
kubectl run ojs-file-copy-$(date +%s) \
  --image=ojs-fstu:latest \
  --restart=Never \
  --namespace=$NAMESPACE \
  --overrides='
{
  "spec": {
    "containers": [{
      "name": "copy-files",
      "image": "ojs-fstu:latest",
      "command": ["sh", "-c"],
      "args": [
        "echo \"Copying files from /var/www/html to /app-volume...\";
         cp -av /var/www/html/* /app-volume/;
         cp -av /var/www/html/.[!.]* /app-volume/ 2>/dev/null || true;
         chown -R 100:101 /app-volume;
         chmod -R 755 /app-volume;
         echo \"Files copied successfully!\";
         ls -la /app-volume/ | head -20"
      ],
      "volumeMounts": [{
        "name": "ojs-app",
        "mountPath": "/app-volume"
      }]
    }],
    "volumes": [{
      "name": "ojs-app",
      "persistentVolumeClaim": {
        "claimName": "ojs-app-fstu-pvc"
      }
    }]
  }
}' \
  --rm -i --attach

echo ""
echo "✅ Copy operation completed!"
echo "📂 Files should now be in /opt/local-path-provisioner/ojs-app-data-fstu"

