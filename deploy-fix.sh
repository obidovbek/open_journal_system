#!/bin/bash

# OJS HTTPS Mixed Content Fix Deployment Script
# This script helps deploy the fixes for mixed content errors

set -e

echo "🚀 OJS HTTPS Mixed Content Fix Deployment"
echo "========================================="

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Creating .env file from template..."
    cp env-template.txt .env
    echo "✅ .env file created. Please edit it with your actual values!"
    echo "   Important: Update passwords and salts before continuing."
    read -p "Press Enter after you've updated .env file..."
fi

# Create necessary directories
echo "📁 Creating data directories..."
mkdir -p data/ojs_files
mkdir -p data/ojs_public
mkdir -p data/mysql
mkdir -p docker/mysql-init

# Set proper permissions
echo "🔐 Setting permissions..."
chmod 755 data/ojs_files
chmod 755 data/ojs_public
chmod 755 data/mysql

# Stop existing containers if running
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Build and start services
echo "🔨 Building and starting OJS services..."
docker-compose build --no-cache
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check service health
echo "🏥 Checking service health..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running"
else
    echo "❌ Some services failed to start. Check logs:"
    docker-compose logs
    exit 1
fi

# Display service status
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🌐 OJS should now be available at: https://publications.fstu.uz"
echo ""
echo "📋 Next Steps:"
echo "1. Update your nginx configuration with the new config from nginx-config-example.conf"
echo "2. Reload nginx: sudo nginx -t && sudo systemctl reload nginx"
echo "3. Access https://publications.fstu.uz/index/install to complete OJS installation"
echo "4. If you still see mixed content errors, enable debug mode in .env (OJS_DEBUG=true) and check logs"
echo ""
echo "🔍 Troubleshooting Commands:"
echo "   View OJS logs: docker-compose logs ojs"
echo "   View MySQL logs: docker-compose logs ojs-mysql"
echo "   Restart services: docker-compose restart"
echo "   Check nginx config: sudo nginx -t"
echo ""
echo "🎉 Deployment complete!" 