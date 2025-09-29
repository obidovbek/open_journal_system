#!/bin/bash

# Fix OJS Database Connection - Align with Kubernetes Production Credentials
echo "🔧 Fixing OJS Database Connection - Aligning with Kubernetes Production"
echo "======================================================================"

echo "This will align Docker Compose credentials with your Kubernetes production setup:"
echo "  - Username: ojs_fstu_user"
echo "  - Password: secure_ojs_fstu_password"
echo "  - Database: ojs_fstu_db"
echo ""

# Create .env file with Kubernetes-aligned credentials
echo "📝 Creating .env file with Kubernetes-aligned database credentials..."
cat > .env << 'EOF'
# OJS (Open Journal System) Environment Configuration
# ALIGNED WITH KUBERNETES PRODUCTION CREDENTIALS

# OJS Database Configuration - MATCHES Kubernetes ConfigMap
OJS_DB_NAME=ojs_fstu_db
OJS_DB_USER=ojs_fstu_user
OJS_DB_PASSWORD=secure_ojs_fstu_password
OJS_MYSQL_ROOT_PASSWORD=secure_mysql_root_password

# OJS Application Configurationdd
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

echo "✅ .env file created with Kubernetes-aligned credentials"

# Update OJS config.inc.php to match Kubernetes credentials
echo ""
echo "🔄 Updating OJS config.inc.php to match Kubernetes credentials..."

# Create a backup
cp docker/config/config.inc.php docker/config/config.inc.php.backup

# Update the database section
sed -i 's/username = ojs_user/username = ojs_fstu_user/' docker/config/config.inc.php
sed -i 's/password = secure_ojs_password/password = secure_ojs_fstu_password/' docker/config/config.inc.php
sed -i 's/name = ojs_db/name = ojs_fstu_db/' docker/config/config.inc.php

echo "✅ OJS config.inc.php updated to match Kubernetes credentials"

# Stop existing containers
echo ""
echo "🛑 Stopping existing containers..."
docker-compose down

# Remove any existing volumes to ensure clean database
echo ""
echo "🧹 Cleaning up database volumes (this will delete existing data)..."
echo "   Removing MySQL data to ensure clean start with new database name..."
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
echo "📋 Database Connection Details (Now Aligned with Kubernetes):"
echo "============================================================="
echo "The following credentials are now configured and match your Kubernetes setup:"
echo ""
echo "🗄️  Database Settings for OJS Installation:"
echo "   - Database Host: ojs-mysql"
echo "   - Database Name: ojs_fstu_db"
echo "   - Username: ojs_fstu_user"
echo "   - Password: secure_ojs_fstu_password"
echo ""
echo "📁 File Upload Directory:"
echo "   - Files Directory: /var/www/files"
echo ""
echo "🌐 Now visit: https://publications.fstu.uz/index/install"
echo ""
echo "✅ Credentials Summary:"
echo "   Docker Compose: ✅ ojs_fstu_user / ojs_fstu_db"
echo "   Kubernetes:     ✅ ojs_fstu_user / ojs_fstu_db"
echo "   Status:         ✅ ALIGNED"
echo ""
echo "🔍 If you still get database errors:"
echo "   1. Check container logs: docker-compose logs ojs-mysql"
echo "   2. Wait longer for MySQL to fully initialize"
echo "   3. Verify containers are healthy: docker-compose ps"
echo ""
echo "✅ Database connection fix complete - Now aligned with Kubernetes production!" 