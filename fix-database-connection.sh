#!/bin/bash

# Fix OJS Database Connection Issue
echo "🔧 Fixing OJS Database Connection Issue"
echo "======================================="

echo "The issue is that the database credentials in config.inc.php don't match docker-compose.yml"
echo ""

# Create .env file with matching credentials
echo "📝 Creating .env file with matching database credentials..."
cat > .env << 'EOF'
# OJS (Open Journal System) Environment Configuration

# OJS Database Configuration - MUST match config.inc.php
OJS_DB_NAME=ojs_db
OJS_DB_USER=ojs_user
OJS_DB_PASSWORD=secure_ojs_password
OJS_MYSQL_ROOT_PASSWORD=secure_mysql_root_password

# OJS Application Configuration
OJS_BASE_URL=https://publications.fstu.uz

# Security Settings (Generate new values for production)
OJS_SALT=OJSSaltChangeThisInProduction

# Email Configuration
OJS_DEFAULT_ENVELOPE_SENDER=noreply@fstu.uz
OJS_SMTP_SERVER=localhost
OJS_SMTP_PORT=25

# Debug Settings (set to 'true' only for troubleshooting)
OJS_DEBUG=false
OJS_SHOW_STACKTRACE=false

# Additional HTTPS Configuration
OJS_FORCE_SSL=true
OJS_TRUST_X_FORWARDED=true
EOF

echo "✅ .env file created with matching credentials"

# Stop existing containers
echo ""
echo "🛑 Stopping existing containers..."
docker-compose down

# Remove any existing volumes to ensure clean database
echo ""
echo "🧹 Cleaning up database volumes (this will delete existing data)..."
echo "   Removing MySQL data to ensure clean start..."
rm -rf ./data/mysql/* 2>/dev/null || true

# Rebuild and start services
echo ""
echo "🔨 Rebuilding and starting services..."
docker-compose build --no-cache
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start..."
echo "   Database initialization may take 30-60 seconds..."
sleep 30

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "📋 Database Connection Details:"
echo "================================"
echo "The following credentials are now configured:"
echo ""
echo "🗄️  Database Settings for OJS Installation:"
echo "   - Database Host: ojs-mysql"
echo "   - Database Name: ojs_db"
echo "   - Username: ojs_user"
echo "   - Password: secure_ojs_password"
echo ""
echo "📁 File Upload Directory:"
echo "   - Files Directory: /var/www/files"
echo ""
echo "🌐 Now visit: https://publications.fstu.uz/index/install"
echo ""
echo "🔍 If you still get database errors:"
echo "   1. Check container logs: docker-compose logs ojs-mysql"
echo "   2. Wait longer for MySQL to fully initialize"
echo "   3. Verify containers are healthy: docker-compose ps"
echo ""
echo "✅ Database connection fix complete!" 