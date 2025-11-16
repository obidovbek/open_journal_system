#!/bin/bash

# Force copy OJS files from Docker image to volume
# This extracts files directly from the image without needing a running pod

NAMESPACE="ojs-fstu"
VOLUME_PATH="/opt/local-path-provisioner/ojs-app-data-fstu"
IMAGE_NAME="ojs-fstu:latest"

echo "🚀 Force copying OJS files from image to volume..."
echo ""

# Ensure volume directory exists
echo "📁 Ensuring volume directory exists..."
mkdir -p "$VOLUME_PATH"
chmod 755 "$VOLUME_PATH"

# Check if directory is empty or has very few files
FILE_COUNT=$(ls -A "$VOLUME_PATH" 2>/dev/null | wc -l)
echo "Current file count: $FILE_COUNT"

if [ "$FILE_COUNT" -gt 10 ]; then
    echo "⚠️  Volume already contains files. Do you want to overwrite? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Aborted"
        exit 0
    fi
    echo "🗑️  Clearing existing files..."
    rm -rf "$VOLUME_PATH"/*
    rm -rf "$VOLUME_PATH"/.[!.]*
fi

echo ""
echo "📦 Extracting files from Docker image: $IMAGE_NAME"
echo "Destination: $VOLUME_PATH"
echo ""

# Create a temporary container from the image and copy files
CONTAINER_ID=$(docker create "$IMAGE_NAME")

if [ -z "$CONTAINER_ID" ]; then
    echo "❌ Failed to create container from image"
    echo "Make sure the image exists: docker images | grep ojs-fstu"
    exit 1
fi

echo "✅ Created temporary container: $CONTAINER_ID"
echo "📋 Copying files..."

# Copy files from container to host
docker cp "$CONTAINER_ID:/var/www/html/." "$VOLUME_PATH/"

# Remove temporary container
echo "🧹 Cleaning up temporary container..."
docker rm "$CONTAINER_ID" > /dev/null

# Create public directory (will be mounted separately)
mkdir -p "$VOLUME_PATH/public"

# Set proper permissions
echo "🔐 Setting permissions..."
chown -R 100:101 "$VOLUME_PATH"
chmod -R 755 "$VOLUME_PATH"

echo ""
echo "✅ Files copied successfully!"
echo ""
echo "📂 Volume contents:"
ls -lah "$VOLUME_PATH" | head -20

echo ""
echo "📊 Statistics:"
du -sh "$VOLUME_PATH"
echo "Total files: $(find "$VOLUME_PATH" -type f 2>/dev/null | wc -l)"

echo ""
echo "🎉 Done! OJS files are now in $VOLUME_PATH"
echo "You can now modify files directly in this directory."

