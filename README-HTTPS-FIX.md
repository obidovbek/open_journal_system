# OJS HTTPS Mixed Content Fix

This document explains how to fix the mixed content errors you're experiencing with your OJS (Open Journal System) installation behind an HTTPS reverse proxy.

## Problem Description

You were experiencing these errors:

- Mixed Content: HTTPS page requesting HTTP stylesheets/scripts
- `$ is not defined` (jQuery not loading)
- `pkp is not defined` (PKP framework not loading)
- Form submitting to HTTP instead of HTTPS

## Root Causes

1. **Improper HTTPS detection**: OJS wasn't detecting that it was behind an HTTPS proxy
2. **Missing proxy headers**: Nginx wasn't sending all necessary forwarded headers
3. **URL generation**: OJS was generating HTTP URLs instead of HTTPS URLs
4. **Security headers**: Missing headers to enforce HTTPS

## Solution Overview

The fix involves multiple components:

### 1. Enhanced HTTPS Detection (`https_forwarded.php`)

- Comprehensive proxy header detection
- Force HTTPS for your domain
- Content Security Policy headers
- Debug logging capability

### 2. Improved OJS Configuration (`config.inc.php`)

- Enhanced proxy trust settings
- Forced SSL configuration
- Security headers

### 3. Better Apache Configuration (`apache-https.conf`)

- Proper HTTPS environment detection
- Security headers
- Rewrite rules for HTTPS enforcement

### 4. Updated Nginx Configuration (`nginx-config-example.conf`)

- All necessary forwarded headers
- Security headers
- Optimized static file handling

## Deployment Instructions

### Step 1: Update Your Files

All the necessary files have been updated in your project. The key changes are:

- `docker/config/config.inc.php` - Enhanced OJS configuration
- `docker/https_forwarded.php` - Improved HTTPS detection
- `docker/apache-https.conf` - Better Apache configuration
- `docker/Dockerfile` - Enhanced container setup
- `docker-compose.yml` - Added health checks and debug options
- `nginx-config-example.conf` - Improved nginx configuration

### Step 2: Update Your Environment

1. Copy the environment template:

   ```bash
   cp env-template.txt .env
   ```

2. Edit `.env` and update these values:
   ```bash
   OJS_DB_PASSWORD=your_secure_password
   OJS_MYSQL_ROOT_PASSWORD=your_secure_root_password
   OJS_SALT=your_unique_salt_string
   OJS_DEBUG=false  # Set to true only for troubleshooting
   ```

### Step 3: Deploy the Fixed Version

Run the deployment script:

```bash
chmod +x deploy-fix.sh
./deploy-fix.sh
```

Or manually:

```bash
# Stop existing containers
docker-compose down

# Rebuild with fixes
docker-compose build --no-cache

# Start services
docker-compose up -d

# Check status
docker-compose ps
```

### Step 4: Update Nginx Configuration

Replace your current nginx configuration with the content from `nginx-config-example.conf`. The key additions are:

```nginx
# CRITICAL: HTTPS forwarding headers
proxy_set_header X-Forwarded-Proto https;
proxy_set_header X-Forwarded-Port 443;
proxy_set_header X-Forwarded-SSL on;
proxy_set_header X-Forwarded-Host $host;

# Security headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "upgrade-insecure-requests" always;
```

Then reload nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### Step 5: Complete OJS Installation

1. Access https://publications.fstu.uz/index/install
2. The mixed content errors should now be resolved
3. Complete the OJS installation process

## Troubleshooting

### If you still see mixed content errors:

1. **Enable debug mode**:

   ```bash
   # In .env file
   OJS_DEBUG=true

   # Restart container
   docker-compose restart ojs
   ```

2. **Check logs**:

   ```bash
   # OJS application logs
   docker-compose logs ojs

   # Nginx logs
   sudo tail -f /var/log/nginx/pub-fstu-error.log
   ```

3. **Verify headers**:

   ```bash
   # Check what headers nginx is sending
   curl -I https://publications.fstu.uz
   ```

4. **Test proxy headers**:
   ```bash
   # Test from inside container
   docker-compose exec ojs printenv | grep -i forward
   ```

### Common Issues and Solutions

#### Issue: Still getting HTTP URLs

**Solution**: Ensure nginx is sending `X-Forwarded-Proto: https` header

#### Issue: CSS/JS still loading over HTTP

**Solution**: Clear OJS cache and browser cache, check Content-Security-Policy headers

#### Issue: Installation form still submits to HTTP

**Solution**: Verify `force_ssl = On` in config.inc.php and restart container

#### Issue: jQuery/PKP not defined errors

**Solution**: Check that static files are being served correctly through the proxy

## Security Considerations

The fix includes several security enhancements:

1. **Strict Transport Security (HSTS)**: Forces HTTPS for future visits
2. **Content Security Policy**: Upgrades insecure requests to HTTPS
3. **X-Content-Type-Options**: Prevents MIME sniffing attacks
4. **X-Frame-Options**: Prevents clickjacking
5. **Referrer-Policy**: Controls referrer information

## Testing

After deployment, test these scenarios:

1. ✅ https://publications.fstu.uz loads without mixed content errors
2. ✅ Installation page loads all CSS and JavaScript
3. ✅ Forms submit to HTTPS endpoints
4. ✅ Static assets (CSS, JS, images) load over HTTPS
5. ✅ Browser developer console shows no security warnings

## Files Modified

- `docker/config/config.inc.php` - OJS configuration
- `docker/https_forwarded.php` - HTTPS detection script
- `docker/apache-https.conf` - Apache proxy configuration
- `docker/Dockerfile` - Container setup
- `docker-compose.yml` - Service orchestration
- `env-template.txt` - Environment variables
- `nginx-config-example.conf` - Nginx proxy configuration (new)
- `deploy-fix.sh` - Deployment script (new)

## Support

If you continue to experience issues:

1. Enable debug mode (`OJS_DEBUG=true` in .env)
2. Check all logs (nginx, docker, OJS)
3. Verify all proxy headers are being sent correctly
4. Test with browser developer tools network tab

The configuration now includes comprehensive HTTPS detection and should resolve all mixed content issues when properly deployed.
