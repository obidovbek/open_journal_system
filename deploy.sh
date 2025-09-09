#!/bin/bash

# OJS HTTPS Proxy Deployment Script
# This script rebuilds and restarts OJS with proper HTTPS configuration

echo "🚀 Starting OJS deployment with HTTPS proxy support..."

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env-template.txt .env
    echo "⚠️  Please edit .env file with your actual database passwords!"
fi

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Rebuild the OJS image with new configuration
echo "🔨 Rebuilding OJS image..."
docker-compose build --no-cache ojs

# Start services
echo "🚀 Starting services..."
docker-compose up -d
#
# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Show status
echo "📊 Service status:"
docker-compose ps

# Show logs
echo "📋 Recent logs:"
docker-compose logs --tail=20 ojs

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🔗 Your OJS should now be accessible at: https://publications.fstu.uz"
echo ""
echo "📋 Important notes:"
echo "   - Make sure your nginx proxy is configured correctly"
echo "   - Check that SSL certificates are valid"
echo "   - Monitor logs with: docker-compose logs -f ojs"
echo ""
echo "🔧 If you still see mixed content errors:"
echo "   1. Check nginx proxy headers (X-Forwarded-Proto, X-Forwarded-Port)"
echo "   2. Verify base_url in OJS admin settings"
echo "   3. Clear browser cache and try incognito mode" 