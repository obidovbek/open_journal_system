# OJS Kubernetes Production Deployment Guide

## Problem Fixed

This guide addresses the **database connection error** you experienced:

```
SQLSTATE[HY000] [2002] No such file or directory
```

### Root Cause

The error occurred because:

1. **Hardcoded database host**: The `config.inc.php` had `host = ojs-mysql` (Docker Compose service name)
2. **Wrong service name**: In Kubernetes, the MySQL service is `ojs-mysql-service-fstu`
3. **Static configuration**: The config file couldn't adapt to different environments
4. **No wait mechanism**: OJS started before MySQL was ready

### Solution

This deployment includes:

- ✅ **Dynamic config generation**: Config file created from environment variables at startup
- ✅ **Correct service names**: Uses proper Kubernetes service DNS names
- ✅ **Database wait logic**: Container waits for MySQL to be ready before starting
- ✅ **Production credentials**: Uses your actual database credentials from `env-template.txt`
- ✅ **HTTPS support**: Proper proxy detection for nginx/Traefik setup

---

## Architecture Overview

```
User (HTTPS)
    ↓
Nginx Proxy (SSL termination, 192.168.10.119)
    ↓
Kubernetes Ingress (Traefik)
    ↓
OJS Service (ClusterIP)
    ↓
OJS Pod ←→ MySQL Pod
```

---

## Prerequisites

1. **Kubernetes cluster** with kubectl configured
2. **Docker** installed for building images
3. **Traefik ingress controller** installed
4. **Nginx proxy** with SSL certificate (already configured)
5. **Persistent storage** available in your cluster

---

## Quick Deployment

### Step 1: Review and Update Configuration

Before deploying, review the database credentials in the ConfigMap:

```bash
# Edit if needed
nano k8s/overlays/fstu/ojs-configmap-production.yaml
```

**Important**: The default values use:
- Database: `ojs2`
- Username: `ojs2`
- Password: `EneTorYpHAWB`

These match the credentials in your `env-template.txt`. Change them if needed.

### Step 2: Deploy to Kubernetes

```bash
cd k8s/overlays/fstu
chmod +x deploy-production.sh
./deploy-production.sh
```

The script will:
1. Build the Kubernetes-specific Docker image
2. Create the namespace
3. Create persistent volume claims
4. Deploy ConfigMap and Secrets
5. Deploy MySQL database
6. Deploy OJS application
7. Apply ingress rules
8. Display deployment status

### Step 3: Verify Deployment

Check that all pods are running:

```bash
kubectl get pods -n ojs-fstu
```

Expected output:
```
NAME                                          READY   STATUS    RESTARTS   AGE
ojs-deployment-fstu-xxxxx                     1/1     Running   0          2m
ojs-mysql-deployment-fstu-xxxxx               1/1     Running   0          3m
```

### Step 4: Check Database Connectivity

View the OJS startup logs to confirm database connection:

```bash
kubectl logs -l app=ojs-fstu -n ojs-fstu
```

You should see:
```
===== OJS Kubernetes Startup =====
Generating config.inc.php from environment variables...
Database Host: ojs-mysql-service-fstu
Database Name: ojs2
Database User: ojs2
Base URL: https://publications.fstu.uz
Config file generated successfully!

===== Waiting for database to be ready =====
Connection to ojs-mysql-service-fstu 3306 port [tcp/mysql] succeeded!
Database is ready!

===== Starting Apache =====
```

### Step 5: Complete OJS Installation

1. Access the installation wizard:
   ```
   https://publications.fstu.uz/index/install/install
   ```

2. The installation should proceed without database errors

3. Complete the installation wizard with your admin credentials

---

## Configuration Details

### Database Configuration

The deployment uses these database settings (defined in ConfigMap):

| Setting | Value | Source |
|---------|-------|--------|
| Host | `ojs-mysql-service-fstu` | Kubernetes service DNS |
| Database | `ojs2` | env-template.txt |
| Username | `ojs2` | env-template.txt |
| Password | `EneTorYpHAWB` | env-template.txt |

### HTTPS Configuration

OJS is configured to work behind your nginx proxy:

| Setting | Value | Purpose |
|---------|-------|---------|
| BASE_URL | `https://publications.fstu.uz` | All URLs use HTTPS |
| HTTPS | `on` | Tells PHP it's using HTTPS |
| SERVER_PORT | `443` | Generates correct URLs |
| force_ssl | `On` | Forces SSL in OJS |
| trust_x_forwarded_for | `On` | Trusts proxy headers |

---

## Troubleshooting

### Issue 1: Database Connection Failed

**Symptoms:**
```
SQLSTATE[HY000] [2002] No such file or directory
```

**Solutions:**

1. **Check MySQL pod status:**
   ```bash
   kubectl get pods -l app=ojs-mysql-fstu -n ojs-fstu
   ```

2. **View MySQL logs:**
   ```bash
   kubectl logs -l app=ojs-mysql-fstu -n ojs-fstu
   ```

3. **Verify service DNS:**
   ```bash
   kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- nslookup ojs-mysql-service-fstu
   ```

4. **Test database connection:**
   ```bash
   kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- nc -zv ojs-mysql-service-fstu 3306
   ```

5. **Check credentials:**
   ```bash
   kubectl get secret ojs-fstu-secret -n ojs-fstu -o yaml
   # Decode password:
   echo "RW5lVG9yWXBIQVdC" | base64 -d
   ```

### Issue 2: OJS Pod CrashLoopBackOff

**Check the logs:**
```bash
kubectl logs -l app=ojs-fstu -n ojs-fstu --previous
```

**Common causes:**
- Database not ready → Wait longer or check MySQL
- Wrong credentials → Verify secrets
- Permission issues → Check init container logs

### Issue 3: 404 Not Found / Ingress Issues

**Verify ingress:**
```bash
kubectl get ingress -n ojs-fstu -o wide
kubectl describe ingress ojs-fstu-ingress -n ojs-fstu
```

**Check service endpoints:**
```bash
kubectl get endpoints -n ojs-fstu
```

**Test service directly:**
```bash
kubectl port-forward svc/ojs-service-fstu 8080:80 -n ojs-fstu
# Then visit: http://localhost:8080
```

### Issue 4: Mixed Content Errors

If you still see HTTP resources on HTTPS pages:

1. **Verify environment variables in pod:**
   ```bash
   kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- env | grep -E "(HTTPS|BASE_URL|SERVER_PORT)"
   ```

2. **Check generated config:**
   ```bash
   kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- cat /var/www/html/config.inc.php | grep -E "(base_url|force_ssl)"
   ```

3. **Verify nginx headers:**
   Check that your nginx is sending:
   - `X-Forwarded-Proto: https`
   - `X-Forwarded-Port: 443`

### Issue 5: Permission Errors

**Symptoms:**
```
Warning: file_put_contents(): Permission denied
```

**Solution:**
```bash
# Check init container logs
kubectl logs -l app=ojs-fstu -n ojs-fstu -c fix-permissions

# Manually fix if needed
kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- sh
chown -R apache:apache /var/www/files /var/www/html/public
chmod -R 755 /var/www/files /var/www/html/public
```

---

## Manual Verification Steps

### 1. Check All Resources

```bash
# All resources in namespace
kubectl get all -n ojs-fstu

# ConfigMaps
kubectl get configmap -n ojs-fstu

# Secrets
kubectl get secrets -n ojs-fstu

# PVCs
kubectl get pvc -n ojs-fstu

# Ingress
kubectl get ingress -n ojs-fstu
```

### 2. View Pod Details

```bash
# Describe OJS pod
kubectl describe pod -l app=ojs-fstu -n ojs-fstu

# Describe MySQL pod
kubectl describe pod -l app=ojs-mysql-fstu -n ojs-fstu
```

### 3. Interactive Debugging

```bash
# Shell into OJS container
kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- sh

# Inside the container:
# - Check config: cat /var/www/html/config.inc.php
# - Check permissions: ls -la /var/www/files
# - Test database: nc -zv ojs-mysql-service-fstu 3306
# - Check PHP: php -v
```

### 4. Database Access

```bash
# Connect to MySQL
kubectl exec -it deployment/ojs-mysql-deployment-fstu -n ojs-fstu -- mysql -u ojs2 -p

# Enter password: EneTorYpHAWB

# Check databases:
SHOW DATABASES;
USE ojs2;
SHOW TABLES;
```

---

## Updating the Deployment

### Update Configuration

```bash
# Edit ConfigMap
kubectl edit configmap ojs-fstu-config -n ojs-fstu

# Or apply updated file
kubectl apply -f ojs-configmap-production.yaml

# Restart OJS to pick up changes
kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu
```

### Update Secrets

```bash
# Edit secrets
kubectl edit secret ojs-fstu-secret -n ojs-fstu

# Or apply updated file
kubectl apply -f ojs-configmap-production.yaml

# Restart to pick up changes
kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu
```

### Rebuild and Redeploy Image

```bash
# Rebuild image
cd /path/to/project
docker build -f docker/Dockerfile.k8s -t ojs-fstu:k8s ./docker/

# Force pull new image
kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu
```

---

## Monitoring

### Real-time Logs

```bash
# Follow OJS logs
kubectl logs -f -l app=ojs-fstu -n ojs-fstu

# Follow MySQL logs
kubectl logs -f -l app=ojs-mysql-fstu -n ojs-fstu

# All logs from namespace
kubectl logs -f -l app -n ojs-fstu --all-containers=true
```

### Resource Usage

```bash
# Pod resource usage
kubectl top pods -n ojs-fstu

# Node resource usage
kubectl top nodes
```

### Events

```bash
# Recent events in namespace
kubectl get events -n ojs-fstu --sort-by='.lastTimestamp'
```

---

## Clean Up

### Remove Deployment (Keep Data)

```bash
kubectl delete deployment ojs-deployment-fstu -n ojs-fstu
kubectl delete deployment ojs-mysql-deployment-fstu -n ojs-fstu
```

### Remove Everything (Including Data)

```bash
kubectl delete namespace ojs-fstu
```

**Warning**: This will delete all data including uploaded files and database!

---

## Production Checklist

Before going live:

- [ ] Update database credentials in secrets
- [ ] Change OJS_SALT to a unique value
- [ ] Configure email settings (SMTP)
- [ ] Set up database backups
- [ ] Configure persistent volume backups
- [ ] Enable resource limits and requests
- [ ] Set up monitoring and alerting
- [ ] Configure ingress rate limiting
- [ ] Review security headers in nginx
- [ ] Test SSL certificate renewal
- [ ] Document recovery procedures
- [ ] Set up log aggregation

---

## Backup and Recovery

### Backup Database

```bash
# Create database dump
kubectl exec deployment/ojs-mysql-deployment-fstu -n ojs-fstu -- \
  mysqldump -u ojs2 -pEneTorYpHAWB ojs2 > ojs-backup-$(date +%Y%m%d).sql
```

### Backup Files

```bash
# Copy files from PVC
kubectl cp ojs-fstu/ojs-deployment-fstu-xxxxx:/var/www/files ./ojs-files-backup
```

### Restore Database

```bash
# Restore from dump
kubectl exec -i deployment/ojs-mysql-deployment-fstu -n ojs-fstu -- \
  mysql -u ojs2 -pEneTorYpHAWB ojs2 < ojs-backup-20241002.sql
```

---

## Differences from Docker Compose

| Aspect | Docker Compose | Kubernetes |
|--------|----------------|------------|
| Database host | `ojs-mysql` | `ojs-mysql-service-fstu` |
| Config file | Mounted from host | Generated at startup |
| Environment vars | `.env` file | ConfigMap + Secrets |
| Service discovery | Container names | Service DNS names |
| Networking | Bridge network | Cluster networking |
| Storage | Host volumes | PersistentVolumeClaims |

---

## Support and Resources

- **OJS Documentation**: https://docs.pkp.sfu.ca/
- **PKP Support Forum**: https://forum.pkp.sfu.ca/
- **Kubernetes Docs**: https://kubernetes.io/docs/

## Files Created

This solution includes:

1. `docker/Dockerfile.k8s` - Kubernetes-specific image with dynamic config
2. `docker/entrypoint-k8s.sh` - Startup script that generates config from env vars
3. `k8s/overlays/fstu/ojs-configmap-production.yaml` - Production ConfigMap and Secrets
4. `k8s/overlays/fstu/ojs-deployment-production.yaml` - Production deployment
5. `k8s/overlays/fstu/deploy-production.sh` - Automated deployment script
6. `K8S-DEPLOYMENT-GUIDE.md` - This guide

---

**Your database connection error is now fixed!** 🎉

The OJS installation should now proceed successfully with proper database connectivity.

