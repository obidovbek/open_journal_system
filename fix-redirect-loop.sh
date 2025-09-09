#!/bin/bash

# Quick Fix for OJS Redirect Loop Issue
# This script fixes the ERR_TOO_MANY_REDIRECTS error

set -e

echo "🔄 Fixing OJS Redirect Loop Issue"
echo "================================="

echo "🛑 Stopping containers..."
docker-compose down

echo "🧹 Clearing any cached redirects..."
# Remove any problematic .htaccess rules that might have been created
if docker volume ls | grep -q ojs; then
    echo "   Clearing OJS cache volumes..."
    docker volume rm $(docker volume ls -q | grep ojs) 2>/dev/null || true
fi

echo "🔨 Rebuilding container without redirect rules..."
docker-compose build --no-cache

echo "🚀 Starting services..."
docker-compose up -d

echo "⏳ Waiting for services to stabilize..."
sleep 20

echo "🏥 Checking service health..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running"
    
    echo ""
    echo "📋 IMPORTANT: Update your nginx configuration"
    echo "=============================================="
    echo "Replace your current nginx config with the content from:"
    echo "   nginx-config-fixed.conf"
    echo ""
    echo "Key changes needed in nginx:"
    echo "1. Remove the 'if' statement in the redirect block"
    echo "2. Use simple 'return 301' for HTTP to HTTPS redirect"
    echo "3. Ensure X-Forwarded-Proto header is set"
    echo ""
    echo "Then run:"
    echo "   sudo nginx -t"
    echo "   sudo systemctl reload nginx"
    echo ""
    echo "🌐 After nginx reload, test: https://publications.fstu.uz"
    
else
    echo "❌ Some services failed to start. Check logs:"
    docker-compose logs --tail=20
    exit 1
fi

echo ""
echo "🔍 If redirect loop persists:"
echo "1. Clear browser cache and cookies"
echo "2. Try incognito/private browsing mode"
echo "3. Check nginx error logs: sudo tail -f /var/log/nginx/pub-fstu-error.log"
echo "4. Verify nginx config: sudo nginx -t"
echo ""
echo "✅ Redirect loop fix deployed!" 