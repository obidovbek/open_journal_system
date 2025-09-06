# OJS FSTU Deployment Guide

## Problem Solved

This configuration fixes the mixed content errors and loading issues you were experiencing with OJS behind your nginx proxy server. The main issues were:

1. **Mixed Content Errors**: OJS was configured with HTTP base URL but served over HTTPS
2. **Missing SSL Configuration**: Ingress wasn't properly configured for HTTPS
3. **Proxy Headers**: OJS wasn't aware it was behind an HTTPS proxy

## Prerequisites

Before deploying, ensure you have:

1. **cert-manager** installed in your cluster:

   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
   ```

2. **Traefik** configured with both `web` (80) and `websecure` (443) entrypoints

3. Your nginx proxy server configured as shown (with the X-Forwarded-Proto and X-Forwarded-Port headers)

## Deployment Steps

1. **Deploy the configuration**:

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

   # Check certificate
   kubectl get certificate -n ojs-fstu
   ```

3. **Monitor certificate issuance**:
   ```bash
   kubectl describe certificate publications-fstu-tls -n ojs-fstu
   ```

## Key Changes Made

### 1. ConfigMap Updates (`ojs-configmap.yaml`)

- Changed `BASE_URL` from HTTP to HTTPS
- Added SSL-aware environment variables:
  - `HTTPS: "on"`
  - `HTTP_X_FORWARDED_PROTO: "https"`
  - `HTTP_X_FORWARDED_PORT: "443"`
  - `SERVER_PORT: "443"`

### 2. Ingress Configuration (`ojs-ingress.yaml`)

- Added `websecure` entrypoint for HTTPS
- Configured TLS termination
- Added cert-manager annotations for automatic SSL certificate
- Added HTTPS redirect middleware

### 3. New Files Created

- `cluster-issuer.yaml`: Let's Encrypt certificate issuer
- `https-redirect-middleware.yaml`: HTTP to HTTPS redirect
- `README.md`: This documentation

## Troubleshooting

### If you still see mixed content errors:

1. **Clear browser cache** completely
2. **Check OJS configuration** in the admin panel:
   - Go to Administration > Site Settings
   - Verify the Base URL is set to `https://publications.fstu.uz`
3. **Restart the OJS pods**:
   ```bash
   kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu
   ```

### If certificate isn't issued:

1. **Check cert-manager logs**:

   ```bash
   kubectl logs -n cert-manager deployment/cert-manager
   ```

2. **Check certificate request**:

   ```bash
   kubectl describe certificaterequest -n ojs-fstu
   ```

3. **Verify DNS**: Ensure `publications.fstu.uz` resolves to your server

### If OJS still loads over HTTP:

1. **Check environment variables**:

   ```bash
   kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- env | grep -E "(HTTPS|BASE_URL|FORWARDED)"
   ```

2. **Check OJS config.inc.php**:
   ```bash
   kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- cat /var/www/html/config.inc.php | grep base_url
   ```

## Your Nginx Proxy Configuration

Your current nginx configuration is correct for this setup:

```nginx
location / {
    proxy_redirect           off;
    proxy_set_header         X-Real-IP           $remote_addr;
    proxy_set_header         X-Forwarded-For     $proxy_add_x_forwarded_for;
    proxy_set_header         Host                $http_host;
    proxy_set_header         X-Forwarded-Proto   https;  # ✅ This is crucial
    proxy_set_header         X-Forwarded-Port    443;    # ✅ This is crucial
    proxy_read_timeout 300;
    proxy_connect_timeout 300;
    proxy_send_timeout 300;
    proxy_pass http://192.168.10.119;  # Your k8s cluster
}
```

## Expected Result

After deployment:

- ✅ OJS loads over HTTPS without mixed content errors
- ✅ All assets (CSS, JS, images) load over HTTPS
- ✅ HTTP requests automatically redirect to HTTPS
- ✅ Valid SSL certificate from Let's Encrypt
- ✅ No more `$` or `pkp` undefined errors in console

## Support

If you encounter any issues:

1. Check the logs:

   ```bash
   kubectl logs -f deployment/ojs-deployment-fstu -n ojs-fstu
   ```

2. Verify ingress is working:

   ```bash
   curl -I https://publications.fstu.uz
   ```

3. Test internal connectivity:
   ```bash
   kubectl run test-pod --image=curlimages/curl -i --rm --restart=Never -- curl -I http://ojs-service-fstu.ojs-fstu.svc.cluster.local
   ```
