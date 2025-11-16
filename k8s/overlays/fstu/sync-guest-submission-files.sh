#!/bin/bash

# Script to manually sync guest submission files to OJS pod
# Usage: ./sync-guest-submission-files.sh [pod-name]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
LOCAL_PUBLIC_DIR="$PROJECT_ROOT/data/ojs-app/public"
NAMESPACE="ojs-fstu"

echo "Syncing Guest Submission Files to OJS Pod"
echo "=========================================="
echo ""

# Get pod name if not provided
if [ -z "$1" ]; then
    echo "Finding OJS pod..."
    pod_name=$(kubectl get pods -n "$NAMESPACE" -l app=ojs-fstu -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
    if [ -z "$pod_name" ]; then
        echo "Error: Could not find OJS pod in namespace $NAMESPACE"
        echo "Available pods:"
        kubectl get pods -n "$NAMESPACE"
        exit 1
    fi
else
    pod_name="$1"
fi

echo "Using pod: $pod_name"
echo "Namespace: $NAMESPACE"
echo "Source directory: $LOCAL_PUBLIC_DIR"
echo ""

# Verify source directory exists
if [ ! -d "$LOCAL_PUBLIC_DIR" ]; then
    echo "Error: Source directory not found: $LOCAL_PUBLIC_DIR"
    exit 1
fi

# Check if pod is running
pod_status=$(kubectl get pod "$pod_name" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
if [ "$pod_status" != "Running" ]; then
    echo "Warning: Pod status is '$pod_status', not 'Running'"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Files to sync
files_to_sync=(
    "guest-submission.html"
    "guest-submission.css"
    "guest-submission.js"
    "guest-submission-handler.php"
    "guest-submission-config.php"
    "test-email.php"
)

echo "Files to sync:"
for file in "${files_to_sync[@]}"; do
    if [ -f "$LOCAL_PUBLIC_DIR/$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ✗ $file (not found)"
    fi
done
echo ""

# Confirm
read -p "Copy these files to pod? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Copy files
echo ""
echo "Copying files..."
success_count=0
fail_count=0

for file in "${files_to_sync[@]}"; do
    if [ -f "$LOCAL_PUBLIC_DIR/$file" ]; then
        echo -n "  Copying $file... "
        if kubectl cp "$LOCAL_PUBLIC_DIR/$file" "$pod_name:/var/www/html/public/$file" -n "$NAMESPACE" 2>/dev/null; then
            echo "✓"
            success_count=$((success_count + 1))
        else
            echo "✗ FAILED"
            fail_count=$((fail_count + 1))
        fi
    fi
done

# Copy .htaccess if it exists
if [ -f "$PROJECT_ROOT/data/ojs-app/.htaccess" ]; then
    echo -n "  Copying .htaccess... "
    if kubectl cp "$PROJECT_ROOT/data/ojs-app/.htaccess" "$pod_name:/var/www/html/.htaccess" -n "$NAMESPACE" 2>/dev/null; then
        echo "✓"
    else
        echo "✗ FAILED"
    fi
fi

# Fix permissions
echo ""
echo "Setting permissions..."
kubectl exec -n "$NAMESPACE" "$pod_name" -- sh -c "chown -R 100:101 /var/www/html/public 2>/dev/null || true"
kubectl exec -n "$NAMESPACE" "$pod_name" -- sh -c "find /var/www/html/public -type f -name '*.php' -exec chmod 644 {} \; 2>/dev/null || true"
kubectl exec -n "$NAMESPACE" "$pod_name" -- sh -c "find /var/www/html/public -type f -name '*.html' -exec chmod 644 {} \; 2>/dev/null || true"
kubectl exec -n "$NAMESPACE" "$pod_name" -- sh -c "find /var/www/html/public -type f -name '*.css' -exec chmod 644 {} \; 2>/dev/null || true"
kubectl exec -n "$NAMESPACE" "$pod_name" -- sh -c "find /var/www/html/public -type f -name '*.js' -exec chmod 644 {} \; 2>/dev/null || true"

# Verify files
echo ""
echo "Verifying files in pod..."
echo ""
kubectl exec -n "$NAMESPACE" "$pod_name" -- ls -lah /var/www/html/public/ | grep -E "(guest-submission|test-email)" || {
    echo "Warning: Could not verify files. Listing all files in public directory:"
    kubectl exec -n "$NAMESPACE" "$pod_name" -- ls -la /var/www/html/public/ | head -20
}

echo ""
echo "=========================================="
echo "Sync completed!"
echo "  Successfully copied: $success_count files"
if [ $fail_count -gt 0 ]; then
    echo "  Failed to copy: $fail_count files"
fi
echo ""
echo "Test the form at:"
echo "  https://publications.fstu.uz/itj/public/guest-submission.html"
echo "  https://publications.fstu.uz/itj/public/test-email.php"
echo ""

