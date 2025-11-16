#!/bin/bash

# Script to check and fix OJS volume files
NAMESPACE="ojs-fstu"
VOLUME_PATH="/opt/local-path-provisioner/ojs-app-data-fstu"

echo "🔍 Checking OJS volume status..."
echo ""

# Check if directory exists
if [ ! -d "$VOLUME_PATH" ]; then
    echo "❌ Volume directory doesn't exist: $VOLUME_PATH"
    echo "Creating directory..."
    mkdir -p "$VOLUME_PATH"
    chmod 755 "$VOLUME_PATH"
    echo "✅ Directory created"
else
    echo "✅ Volume directory exists: $VOLUME_PATH"
fi

# Check if directory is empty
FILE_COUNT=$(ls -A "$VOLUME_PATH" 2>/dev/null | wc -l)
echo "📊 Files in volume: $FILE_COUNT"

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "⚠️  Volume is empty!"
    echo ""
    echo "Checking if OJS pod exists..."
    
    POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=ojs-fstu -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -z "$POD_NAME" ]; then
        echo "❌ No OJS pod found. Deploy OJS first:"
        echo "   ./k8s/overlays/fstu/deploy-ojs.sh"
        exit 1
    fi
    
    echo "✅ Found pod: $POD_NAME"
    echo ""
    echo "Checking init container logs..."
    kubectl logs "$POD_NAME" -n $NAMESPACE -c copy-app-files 2>/dev/null || echo "⚠️  Init container logs not available"
    echo ""
    
    echo "🔧 Attempting to copy files manually..."
    echo "This will create a temporary pod to copy OJS files from the image to the volume."
    echo ""
    
    # Create temporary pod to copy files
    TEMP_POD="ojs-manual-copy-$(date +%s)"
    
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: $TEMP_POD
  namespace: $NAMESPACE
spec:
  restartPolicy: Never
  containers:
  - name: copy-files
    image: ojs-fstu:latest
    command:
    - sh
    - -c
    - |
      set -e
      echo "=== Starting manual file copy ==="
      echo "Source: /var/www/html"
      echo "Destination: /app-volume"
      echo ""
      echo "Listing source files..."
      ls -la /var/www/html/ | head -20
      echo ""
      echo "Copying all files..."
      cp -av /var/www/html/* /app-volume/
      echo ""
      echo "Copying hidden files..."
      cp -av /var/www/html/.[!.]* /app-volume/ 2>/dev/null || echo "No hidden files"
      echo ""
      echo "Creating public directory..."
      mkdir -p /app-volume/public
      echo ""
      echo "Setting permissions..."
      chown -R 100:101 /app-volume
      chmod -R 755 /app-volume
      echo ""
      echo "Verifying copy..."
      ls -la /app-volume/ | head -20
      echo ""
      echo "=== Copy completed successfully ==="
    volumeMounts:
    - name: ojs-app
      mountPath: /app-volume
    securityContext:
      runAsUser: 0
      runAsGroup: 0
  volumes:
  - name: ojs-app
    persistentVolumeClaim:
      claimName: ojs-app-fstu-pvc
EOF
    
    echo "⏳ Waiting for copy to complete..."
    kubectl wait --for=condition=Ready pod/$TEMP_POD -n $NAMESPACE --timeout=60s 2>/dev/null || true
    sleep 5
    
    echo ""
    echo "📋 Copy pod logs:"
    kubectl logs $TEMP_POD -n $NAMESPACE
    
    echo ""
    echo "🧹 Cleaning up temporary pod..."
    kubectl delete pod $TEMP_POD -n $NAMESPACE --ignore-not-found=true
    
    echo ""
    echo "✅ Manual copy completed!"
    
else
    echo "✅ Volume contains files"
fi

echo ""
echo "📂 Current volume contents:"
ls -lah "$VOLUME_PATH" | head -20

echo ""
echo "📊 Volume statistics:"
du -sh "$VOLUME_PATH"
echo "Total files: $(find "$VOLUME_PATH" -type f 2>/dev/null | wc -l)"
echo "Total directories: $(find "$VOLUME_PATH" -type d 2>/dev/null | wc -l)"

echo ""
echo "✅ Check complete!"

