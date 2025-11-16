#!/bin/bash

# Script to migrate OJS files from old location to new project-local location
OLD_PATH="/opt/local-path-provisioner/ojs-app-data-fstu"
NEW_PATH="/home/fstu/projects/open_journal_system/data/ojs-app"

echo "🔄 Migrating OJS files to project directory..."
echo ""
echo "From: $OLD_PATH"
echo "To:   $NEW_PATH"
echo ""

# Check if old path exists and has files
if [ ! -d "$OLD_PATH" ]; then
    echo "❌ Old path doesn't exist: $OLD_PATH"
    echo "Nothing to migrate."
    exit 0
fi

OLD_FILE_COUNT=$(ls -A "$OLD_PATH" 2>/dev/null | wc -l)
if [ "$OLD_FILE_COUNT" -eq 0 ]; then
    echo "⚠️  Old path is empty, nothing to migrate."
    exit 0
fi

echo "📊 Found $OLD_FILE_COUNT items in old location"

# Create new directory
echo "📁 Creating new directory..."
mkdir -p "$NEW_PATH"

# Check if new path already has files
NEW_FILE_COUNT=$(ls -A "$NEW_PATH" 2>/dev/null | wc -l)
if [ "$NEW_FILE_COUNT" -gt 0 ]; then
    echo "⚠️  New location already has $NEW_FILE_COUNT files!"
    echo "Do you want to overwrite? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Migration cancelled"
        exit 0
    fi
    echo "🗑️  Clearing new location..."
    rm -rf "$NEW_PATH"/*
    rm -rf "$NEW_PATH"/.[!.]*
fi

# Copy files
echo "📋 Copying files..."
cp -av "$OLD_PATH/." "$NEW_PATH/"

# Set permissions
echo "🔐 Setting permissions..."
chown -R 100:101 "$NEW_PATH"
chmod -R 755 "$NEW_PATH"

echo ""
echo "✅ Migration completed!"
echo "📊 New location contains: $(ls -A "$NEW_PATH" | wc -l) items"
echo ""
echo "🧹 You can now delete the old location if you want:"
echo "   sudo rm -rf $OLD_PATH"
echo ""
echo "🚀 Redeploy OJS to use the new location:"
echo "   ./k8s/overlays/fstu/deploy-ojs.sh"

