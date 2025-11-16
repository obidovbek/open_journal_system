# Fixing 404 Error for Guest Submission Files

## Problem

You're getting a 404 error when trying to access:
```
https://publications.fstu.uz/itj/public/test-email.php
```

## Solutions

### Solution 1: Check File Location (Most Common)

The file needs to be in the correct location in your deployed environment:

1. **Verify the file exists** in the container:
   ```bash
   # If using Docker
   docker exec -it ojs ls -la /var/www/html/public/test-email.php
   
   # If using Kubernetes
   kubectl exec -it <pod-name> -n ojs-fstu -- ls -la /var/www/html/public/test-email.php
   ```

2. **If the file doesn't exist**, copy it to the container:
   ```bash
   # Docker
   docker cp data/ojs-app/public/test-email.php ojs:/var/www/html/public/
   
   # Kubernetes
   kubectl cp data/ojs-app/public/test-email.php <pod-name>:/var/www/html/public/ -n ojs-fstu
   ```

### Solution 2: Try Different URL Paths

Depending on your OJS installation structure, try these URLs:

1. **Journal path included** (if `/itj/` is the journal path):
   ```
   https://publications.fstu.uz/itj/public/test-email.php
   ```

2. **Direct public path**:
   ```
   https://publications.fstu.uz/public/test-email.php
   ```

3. **Without `/itj/`** (if OJS is at root):
   ```
   https://publications.fstu.uz/public/test-email.php
   ```

### Solution 3: Verify .htaccess Configuration

I've updated the `.htaccess` file to allow direct access to files in the `public` directory. Verify it's deployed:

1. **Check the .htaccess file** in the container:
   ```bash
   # Docker
   docker exec -it ojs cat /var/www/html/.htaccess
   
   # Kubernetes
   kubectl exec -it <pod-name> -n ojs-fstu -- cat /var/www/html/.htaccess
   ```

2. **The .htaccess should include** these rules (already added):
   ```apache
   # Allow direct access to existing files and directories (MUST come first)
   RewriteCond %{REQUEST_FILENAME} -f [OR]
   RewriteCond %{REQUEST_FILENAME} -d
   RewriteRule ^ - [L]
   
   # Allow direct access to PHP/HTML/CSS/JS files in public directory
   RewriteCond %{REQUEST_URI} ^/public/.*\.(php|html|css|js)$ [NC]
   RewriteCond %{REQUEST_FILENAME} -f
   RewriteRule ^ - [L]
   ```

3. **If the rules are missing**, copy the updated `.htaccess`:
   ```bash
   # Docker
   docker cp data/ojs-app/.htaccess ojs:/var/www/html/
   
   # Kubernetes
   kubectl cp data/ojs-app/.htaccess <pod-name>:/var/www/html/ -n ojs-fstu
   ```

### Solution 4: Check Apache/Nginx Configuration

If you're using a reverse proxy (nginx), verify it's not blocking the request:

1. **Check nginx logs**:
   ```bash
   tail -f /var/log/nginx/error.log
   tail -f /var/log/nginx/access.log
   ```

2. **Verify nginx passes the request** to the OJS container

3. **Check Apache logs** (inside the container):
   ```bash
   # Docker
   docker exec -it ojs tail -f /var/log/apache2/error.log
   
   # Kubernetes
   kubectl exec -it <pod-name> -n ojs-fstu -- tail -f /var/log/apache2/error.log
   ```

### Solution 5: Check File Permissions

Ensure the file has correct permissions:

```bash
# Docker
docker exec -it ojs chmod 644 /var/www/html/public/test-email.php
docker exec -it ojs chown www-data:www-data /var/www/html/public/test-email.php

# Kubernetes
kubectl exec -it <pod-name> -n ojs-fstu -- chmod 644 /var/www/html/public/test-email.php
kubectl exec -it <pod-name> -n ojs-fstu -- chown www-data:www-data /var/www/html/public/test-email.php
```

### Solution 6: Direct File Access Test

Test if you can access other files in the public directory:

1. **Try accessing the HTML form directly**:
   ```
   https://publications.fstu.uz/itj/public/guest-submission.html
   ```

2. **Try accessing a static file**:
   ```
   https://publications.fstu.uz/itj/public/guest-submission.css
   ```

If these work but the PHP file doesn't, the issue is likely:
- PHP execution is disabled in the public directory
- PHP handler is not configured for `.php` files in public
- File permissions issue

### Solution 7: Deploy Files via Kubernetes Volume Mount

If using Kubernetes, ensure files are properly mounted:

1. **Check if the volume is mounted correctly**:
   ```bash
   kubectl describe pod <pod-name> -n ojs-fstu | grep -A 5 "Mounts:"
   ```

2. **Verify files in the mounted volume**:
   ```bash
   # Check PersistentVolume or PersistentVolumeClaim
   kubectl get pv
   kubectl get pvc -n ojs-fstu
   ```

3. **If using a persistent volume**, ensure files are synced:
   ```bash
   # Copy files to the persistent volume
   kubectl cp data/ojs-app/public/ <pvc-name>:/public/ -n ojs-fstu
   ```

### Solution 8: Create a Route Through OJS (Alternative)

If direct access doesn't work, you can create an OJS plugin or custom route:

1. Create a simple PHP wrapper in the OJS root that includes the test script
2. Access it through OJS routing: `https://publications.fstu.uz/itj/index.php/test-email`

However, this is more complex and not recommended for a test file.

## Quick Fix for Kubernetes Deployment

If you're using Kubernetes and the files aren't being deployed:

1. **Update the deployment to copy files**:

   ```bash
   # Copy files to the pod
   kubectl cp data/ojs-app/public/test-email.php <pod-name>:/var/www/html/public/ -n ojs-fstu
   kubectl cp data/ojs-app/.htaccess <pod-name>:/var/www/html/ -n ojs-fstu
   ```

2. **Restart the pod**:
   ```bash
   kubectl rollout restart deployment ojs-deployment-fstu -n ojs-fstu
   ```

3. **Or add an init container** to copy files on startup (see deployment YAML files)

## Testing

After applying the fix:

1. **Test the file**:
   ```
   curl -I https://publications.fstu.uz/itj/public/test-email.php
   ```

   You should get a `200 OK` response, not `404`.

2. **Access in browser**:
   ```
   https://publications.fstu.uz/itj/public/test-email.php
   ```

3. **Run the email tests** using the buttons on the page

## Verification Checklist

- [ ] File exists at `/var/www/html/public/test-email.php` in container
- [ ] File permissions are correct (644 or 755)
- [ ] File ownership is correct (www-data:www-data)
- [ ] `.htaccess` includes rules to allow direct access
- [ ] Apache can execute PHP files in public directory
- [ ] Nginx (if used) is not blocking the request
- [ ] URL path matches your OJS installation structure
- [ ] Other files in public directory are accessible

## After Testing

**IMPORTANT:** Delete the test file after successful testing for security:

```bash
# Docker
docker exec -it ojs rm /var/www/html/public/test-email.php

# Kubernetes
kubectl exec -it <pod-name> -n ojs-fstu -- rm /var/www/html/public/test-email.php
```

---

## Still Having Issues?

If none of these solutions work:

1. **Check the actual path structure** in your OJS installation:
   ```bash
   kubectl exec -it <pod-name> -n ojs-fstu -- find /var/www/html -name "test-email.php"
   ```

2. **Check what URLs OJS recognizes**:
   - Log in to OJS admin
   - Go to Settings → Website → Appearance
   - Check the base URL and journal path settings

3. **Review the deployment logs**:
   ```bash
   kubectl logs <pod-name> -n ojs-fstu --tail=100
   ```

4. **Check Apache error logs** for more details:
   ```bash
   kubectl exec -it <pod-name> -n ojs-fstu -- tail -50 /var/log/apache2/error.log
   ```

