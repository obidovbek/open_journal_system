#!/bin/bash

echo "🔧 Fixing OJS file upload directory permissions..."

# Check if .env file exists, if not create it from template
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env-template.txt .env
    echo "⚠️  IMPORTANT: Edit .env file with your actual database passwords before running docker-compose!"
    echo "   Default passwords are insecure and should be changed."
fi

# Create directories if they don't exist
mkdir -p ./data/ojs_files
mkdir -p ./data/ojs_public
mkdir -p ./data/mysql

# Set proper permissions for OJS directories
# OJS in Alpine container runs as apache user (uid 100, gid 101)
echo "Setting permissions for ojs_files directory..."
chmod -R 755 ./data/ojs_files
chown -R 100:101 ./data/ojs_files 2>/dev/null || {
    echo "⚠️  Could not set owner to apache (uid 100). This is normal on some systems."
    echo "   The container will handle ownership internally."
    # Make it writable by all as fallback
    chmod -R 777 ./data/ojs_files
}

echo "Setting permissions for ojs_public directory..."
chmod -R 755 ./data/ojs_public
chown -R 100:101 ./data/ojs_public 2>/dev/null || {
    echo "⚠️  Could not set owner to apache (uid 100). This is normal on some systems."
    echo "   The container will handle ownership internally."
    # Make it writable by all as fallback
    chmod -R 777 ./data/ojs_public
}

echo "Setting permissions for mysql directory..."
chmod -R 755 ./data/mysql
chown -R 999:999 ./data/mysql 2>/dev/null || {
    echo "⚠️  Could not set owner to mysql (uid 999). This is normal on some systems."
    echo "   The container will handle ownership internally."
    # Make it writable by all as fallback
    chmod -R 777 ./data/mysql
}

echo "✅ File permissions have been set!"
echo ""
echo "Directory structure:"
ls -la ./data/

echo ""
echo "📋 Next steps:"
echo "   1. Edit .env file with your database passwords"
echo "   2. Run: docker-compose up -d"
echo "   3. Wait for containers to start (database initialization takes time)"
echo "   4. Visit: https://publications.fstu.uz/index/install"
echo ""
echo "🚀 Quick deployment: ./deploy.sh" 