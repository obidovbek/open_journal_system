#!/bin/bash

echo "🚨 OJS Installation Error Fix"
echo "================================"
echo "Error: 'The directory specified for uploaded files does not exist or is not writable.'"
echo ""

# Stop any running containers first
echo "🛑 Stopping any running OJS containers..."
docker-compose down 2>/dev/null || echo "No containers were running."

# Check if .env file exists, if not create it from template
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env-template.txt .env
    echo "⚠️  IMPORTANT: Edit .env file with your actual database passwords!"
    echo "   Current passwords are defaults and should be changed for security."
    echo ""
fi

# Create and fix permissions for upload directories
echo "📁 Creating and fixing upload directory permissions..."

# Create directories if they don't exist
mkdir -p ./data/ojs_files
mkdir -p ./data/ojs_public
mkdir -p ./data/mysql

# Set proper permissions for OJS directories
# OJS in Alpine container runs as apache user (uid 100, gid 101)
echo "   Setting permissions for ojs_files directory..."
chmod -R 755 ./data/ojs_files
if chown -R 100:101 ./data/ojs_files 2>/dev/null; then
    echo "   ✅ Owner set to apache user (uid 100)"
else
    echo "   ⚠️  Could not set owner to apache (uid 100). Using fallback permissions..."
    chmod -R 777 ./data/ojs_files
    echo "   ✅ Fallback permissions set (777)"
fi

echo "   Setting permissions for ojs_public directory..."
chmod -R 755 ./data/ojs_public
if chown -R 100:101 ./data/ojs_public 2>/dev/null; then
    echo "   ✅ Owner set to apache user (uid 100)"
else
    echo "   ⚠️  Could not set owner to apache (uid 100). Using fallback permissions..."
    chmod -R 777 ./data/ojs_public
    echo "   ✅ Fallback permissions set (777)"
fi

echo "   Setting permissions for mysql directory..."
chmod -R 755 ./data/mysql
if chown -R 999:999 ./data/mysql 2>/dev/null; then
    echo "   ✅ Owner set to mysql user (uid 999)"
else
    echo "   ⚠️  Could not set owner to mysql (uid 999). Using fallback permissions..."
    chmod -R 777 ./data/mysql
    echo "   ✅ Fallback permissions set (777)"
fi

echo ""
echo "📊 Current directory structure and permissions:"
ls -la ./data/

echo ""
echo "🔧 Rebuilding and starting containers..."
docker-compose build --no-cache ojs
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start..."
echo "   Database initialization may take 30-60 seconds on first run..."

# Wait for containers to be healthy
for i in {1..30}; do
    if docker-compose ps | grep -q "healthy"; then
        break
    fi
    echo "   Waiting... ($i/30)"
    sleep 2
done

echo ""
echo "📋 Container Status:"
docker-compose ps

echo ""
echo "✅ Fix Applied! Next Steps:"
echo "================================"
echo "1. 🔐 Edit .env file with secure database passwords"
echo "2. 🌐 Visit: https://publications.fstu.uz/index/install"
echo "3. 📝 In the installation form, use this upload directory:"
echo "   /var/www/files"
echo ""
echo "4. 🗄️  Database settings to use:"
echo "   - Host: ojs-mysql"
echo "   - Username: ojs_user (or value from .env)"
echo "   - Password: ojs_password (or value from .env)"
echo "   - Database: ojs_db (or value from .env)"
echo ""
echo "5. 📊 Monitor installation progress:"
echo "   docker-compose logs -f ojs"
echo ""
echo "🚨 If you still get the error:"
echo "   - Wait longer for containers to fully start"
echo "   - Check logs: docker-compose logs ojs"
echo "   - Try restarting: docker-compose restart ojs" 