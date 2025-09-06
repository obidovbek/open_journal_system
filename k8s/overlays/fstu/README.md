# OJS FSTU Deployment Guide - Simplified Approach

## Problem Solved

This configuration fixes the mixed content errors and console errors you were experiencing with OJS behind your nginx proxy server, while avoiding the 404 errors from complex SSL termination.

### Root Cause

1. **Mixed Content Errors**: OJS was configured with HTTP base URL but served over HTTPS
2. **HTTPS Detection**: OJS wasn't aware it was behind an HTTPS proxy
3. **Over-complicated SSL**: Previous attempt with ingress SSL termination caused 404 errors

### Simple Solution

- Keep SSL termination at your nginx proxy (as you already have)
- Use simple HTTP routing in Kubernetes ingress
- Configure OJS to be HTTPS-aware through environment variables

## Prerequisites

You only need:

1. **Traefik** configured with `web` (80) entrypoint
2. Your nginx proxy server configured with the forwarded headers (which you already have)

## Deployment Steps

1. **Deploy the simplified configuration**:

   ```bash
   cd /d/projects/open_journal_system/k8s/overlays/fstu
   chmod +x deploy-ojs.sh
   ./deploy-ojs.sh
   ```

2. **Verify deployment**:

   ```bash
   # Check if pods are running
   kubectl get pods -n ojs-fstu

   # Check ingress
   kubectl get ingress -n ojs-fstu

   # Test internal connectivity
   kubectl port-forward svc/ojs-service-fstu 8080:80 -n ojs-fstu
   # Then test: curl http://localhost:8080
   ```

## Key Changes Made

### 1. ConfigMap Updates (`ojs-configmap.yaml`)

- Changed `BASE_URL` from HTTP to HTTPS: `https://publications.fstu.uz`
- Added minimal SSL-aware environment variables:
  - `HTTPS: "on"` - Tells OJS it's running under HTTPS
  - `SERVER_PORT: "443"` - Makes OJS think it's on port 443

### 2. Simplified Ingress (`ojs-ingress.yaml`)

- **Removed** complex SSL termination, cert-manager, and HTTPS redirects
- Uses simple HTTP routing: `traefik.ingress.kubernetes.io/router.entrypoints: web`
- Routes `publications.fstu.uz` traffic to OJS service on port 80

### 3. Your Nginx Proxy (Already Correct)

Your existing nginx configuration is perfect for this setup:

```nginx
location / {
    proxy_set_header         X-Forwarded-Proto   https;  # ✅
    proxy_set_header         X-Forwarded-Port    443;    # ✅
    proxy_pass http://192.168.10.119;  # Routes to your k8s cluster
}
```

## Traffic Flow

```
Browser (HTTPS) → Nginx Proxy (SSL termination) → Kubernetes Ingress (HTTP) → OJS Pod (HTTP)
     ↑                    ↑                              ↑                    ↑
   Port 443          Handles SSL                   Routes by host        Thinks it's HTTPS
```

## Troubleshooting

### If you still see mixed content errors:

1. **Clear browser cache** completely and restart browser
2. **Restart OJS pods**:
   ```bash
   kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu
   ```
3. **Check environment variables**:
   ```bash
   kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- env | grep -E "(HTTPS|BASE_URL|SERVER_PORT)"
   ```

### If you get 404 errors:

1. **Check ingress status**:

   ```bash
   kubectl get ingress -n ojs-fstu -o wide
   kubectl describe ingress ojs-fstu-ingress -n ojs-fstu
   ```

2. **Verify service and endpoints**:

   ```bash
   kubectl get svc -n ojs-fstu
   kubectl get endpoints -n ojs-fstu
   ```

3. **Test service directly**:
   ```bash
   kubectl port-forward svc/ojs-service-fstu 8080:80 -n ojs-fstu
   curl -H "Host: publications.fstu.uz" http://localhost:8080
   ```

### If OJS admin shows wrong base URL:

1. **Check OJS configuration in admin panel**:

   - Go to Administration > Site Settings
   - Verify Base URL is `https://publications.fstu.uz`

2. **Force update via database** (if needed):
   ```bash
   kubectl exec -it deployment/ojs-mysql-deployment-fstu -n ojs-fstu -- mysql -u root -p
   # Then: UPDATE site_settings SET setting_value='https://publications.fstu.uz' WHERE setting_name='base_url';
   ```

## Expected Results

After deployment:

- ✅ No 404 errors (simple ingress routing works)
- ✅ OJS loads over HTTPS without mixed content errors
- ✅ All assets (CSS, JS, images) load over HTTPS
- ✅ No more `$` or `pkp` undefined errors in console
- ✅ Uses your existing SSL certificate from nginx

## Why This Approach Works

1. **Separation of Concerns**: Nginx handles SSL, Kubernetes handles routing
2. **Minimal Configuration**: Less complexity = fewer failure points
3. **Proven Pattern**: Many production setups use this nginx + k8s pattern
4. **No Certificate Issues**: Uses your existing SSL setup

The key insight is that OJS just needs to _think_ it's running under HTTPS, even though the internal k8s traffic is HTTP.
