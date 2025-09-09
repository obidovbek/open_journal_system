# OJS Redirect Loop Fix (ERR_TOO_MANY_REDIRECTS)

## Problem

You're experiencing `ERR_TOO_MANY_REDIRECTS` when accessing https://publications.fstu.uz because there were conflicting redirect rules between nginx and the OJS container.

## Root Cause

The issue was caused by:

1. **Nginx** was redirecting HTTP → HTTPS (correct)
2. **OJS container** was also trying to redirect to HTTPS via `.htaccess` rules (incorrect)
3. This created an infinite redirect loop

## Solution Applied

### 1. Removed Container-Level Redirects

- Removed the problematic `.htaccess` redirect rule from `Dockerfile`
- Updated Apache configuration to only detect HTTPS, not redirect
- Commented out `force_login_ssl` in OJS config

### 2. Fixed Nginx Configuration

- Simplified HTTP to HTTPS redirect
- Ensured proper forwarded headers are sent
- Added `X-Forwarded-Prefix` header to prevent loops

## Quick Fix Steps

### Step 1: Apply the Container Fix

```bash
# Run the fix script
chmod +x fix-redirect-loop.sh
./fix-redirect-loop.sh
```

### Step 2: Update Nginx Configuration

Replace your current nginx configuration with this corrected version:

```nginx
server {
    server_name publications.fstu.uz;

    # ... logging and security headers ...

    location / {
        proxy_pass http://192.168.10.119:8081;
        proxy_redirect off;

        # Essential headers
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # CRITICAL: Tell container it's behind HTTPS
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Port 443;
        proxy_set_header X-Forwarded-SSL on;
        proxy_set_header X-Forwarded-Host $host;

        # Prevent redirect loops
        proxy_set_header X-Forwarded-Prefix "";
    }

    listen 443 ssl http2;
    # ... SSL configuration ...
}

server {
    # Simple HTTP to HTTPS redirect
    listen 80;
    server_name publications.fstu.uz;
    return 301 https://$host$request_uri;
}
```

### Step 3: Reload Nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### Step 4: Clear Browser Cache

- Clear browser cache and cookies for publications.fstu.uz
- Try accessing the site in incognito/private mode

## Key Changes Made

### In Docker Container:

- ❌ Removed: `.htaccess` redirect rules
- ❌ Removed: `force_login_ssl = On`
- ✅ Kept: HTTPS detection via forwarded headers
- ✅ Kept: Security headers

### In Nginx:

- ✅ Simplified: HTTP to HTTPS redirect
- ✅ Added: `X-Forwarded-Prefix` header
- ✅ Ensured: All forwarded headers are present

## Testing

After applying the fix:

1. ✅ https://publications.fstu.uz should load without redirect errors
2. ✅ HTTP requests should redirect to HTTPS once
3. ✅ No mixed content errors should appear
4. ✅ Installation page should load properly

## Troubleshooting

### If redirect loop persists:

1. **Clear everything**:

   ```bash
   # Clear browser data completely
   # Try different browser or incognito mode
   ```

2. **Check nginx logs**:

   ```bash
   sudo tail -f /var/log/nginx/pub-fstu-error.log
   ```

3. **Verify nginx config**:

   ```bash
   sudo nginx -t
   sudo nginx -T | grep publications.fstu.uz -A 20
   ```

4. **Check container logs**:
   ```bash
   docker-compose logs ojs | grep -i redirect
   ```

### If still having issues:

1. **Temporarily disable HTTPS redirect** in nginx to test:

   ```nginx
   server {
       listen 80;
       server_name publications.fstu.uz;
       # Comment out the redirect temporarily
       # return 301 https://$host$request_uri;

       location / {
           proxy_pass http://192.168.10.119:8081;
           # ... other proxy settings ...
       }
   }
   ```

2. **Test HTTP first**: http://publications.fstu.uz (temporarily)
3. **Then re-enable HTTPS redirect** once working

## Files Modified

- `docker/Dockerfile` - Removed redirect rules
- `docker/apache-https.conf` - Removed redirect, kept detection
- `docker/config/config.inc.php` - Disabled force_login_ssl
- `nginx-config-fixed.conf` - Simplified redirect logic

## Prevention

To prevent this in the future:

- ✅ Only nginx should handle HTTP → HTTPS redirects
- ✅ Container should only detect HTTPS, never redirect
- ✅ Always test redirect logic in isolation
- ✅ Use browser dev tools to trace redirect chains
