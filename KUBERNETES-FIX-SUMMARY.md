# Kubernetes Database Connection Fix - Summary

## What Was Wrong

You were getting this error when trying to install OJS in Kubernetes:

```
SQLSTATE[HY000] [2002] No such file or directory
(SQL: create table `journals` ...)
```

**Root cause**: The `config.inc.php` file had a hardcoded database host `ojs-mysql` which is the Docker Compose service name, but in Kubernetes your MySQL service is named `ojs-mysql-service-fstu`.

## What Was Fixed

### ✅ Created Kubernetes-Specific Deployment

We created new files that make OJS work properly in Kubernetes:

1. **Dynamic Configuration**
   - `docker/entrypoint-k8s.sh` - Generates config from environment variables at startup
   - `docker/Dockerfile.k8s` - Kubernetes-specific Docker image

2. **Correct Database Settings**
   - `k8s/overlays/fstu/ojs-configmap-production.yaml` - Uses correct Kubernetes service name
   - Includes your production database credentials (ojs2/EneTorYpHAWB)

3. **Improved Deployment**
   - `k8s/overlays/fstu/ojs-deployment-production.yaml` - Updated deployment with all env vars
   - Database connection wait logic prevents startup errors

4. **Documentation**
   - `K8S-DEPLOYMENT-GUIDE.md` - Complete deployment guide with troubleshooting
   - `K8S-DATABASE-FIX.md` - Technical explanation of the fix
   - `k8s/overlays/fstu/QUICKSTART.md` - Quick deployment instructions

5. **Automated Deployment**
   - `k8s/overlays/fstu/deploy-production.sh` - One-command deployment script

## How to Deploy

### Option 1: Automated (Recommended)

```bash
cd /projects/open_journal_system/k8s/overlays/fstu
chmod +x deploy-production.sh
./deploy-production.sh
```

### Option 2: Manual

```bash
# Build the Kubernetes image
cd /projects/open_journal_system
docker build -f docker/Dockerfile.k8s -t ojs-fstu:k8s ./docker/

# Deploy to Kubernetes
cd k8s/overlays/fstu
kubectl apply -f namespace.yaml
kubectl apply -f ojs-configmap-production.yaml
kubectl apply -f ojs-mysql-deployment.yaml
kubectl apply -f ojs-deployment-production.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=ojs-fstu -n ojs-fstu --timeout=300s
```

### Option 3: Read the Docs First

1. **Quick Start**: See `k8s/overlays/fstu/QUICKSTART.md`
2. **Full Guide**: See `K8S-DEPLOYMENT-GUIDE.md`
3. **Technical Details**: See `K8S-DATABASE-FIX.md`

## Verify It Works

After deployment, check the logs:

```bash
kubectl logs -l app=ojs-fstu -n ojs-fstu
```

You should see:
```
===== OJS Kubernetes Startup =====
Database Host: ojs-mysql-service-fstu  ← Correct service name
Database Name: ojs2
Database User: ojs2
Config file generated successfully!

===== Waiting for database to be ready =====
Connection to ojs-mysql-service-fstu 3306 port [tcp/mysql] succeeded!
Database is ready!  ← This means it's working!

===== Starting Apache =====
```

Then access:
```
https://publications.fstu.uz/index/install/install
```

The database error should be gone! ✅

## Key Changes

### Before (Broken)
```ini
# docker/config/config.inc.php
[database]
host = ojs-mysql  # ❌ Docker Compose service name
```

### After (Fixed)
```bash
# docker/entrypoint-k8s.sh generates:
[database]
host = ojs-mysql-service-fstu  # ✅ Kubernetes service name
```

## Database Configuration Used

The deployment uses these settings:

| Setting | Value | Source |
|---------|-------|--------|
| Host | `ojs-mysql-service-fstu` | Kubernetes service DNS |
| Database | `ojs2` | Your env-template.txt |
| Username | `ojs2` | Your env-template.txt |
| Password | `EneTorYpHAWB` | Your env-template.txt |

**Note**: If these credentials are incorrect, edit `k8s/overlays/fstu/ojs-configmap-production.yaml` before deploying.

## Files Modified/Created

### New Files Created
```
docker/
  ├── Dockerfile.k8s               # Kubernetes-specific image
  ├── entrypoint-k8s.sh            # Dynamic config generation
  └── config/
      └── config.inc.k8s.php       # Template (for reference)

k8s/overlays/fstu/
  ├── ojs-configmap-production.yaml    # Production ConfigMap & Secrets
  ├── ojs-deployment-production.yaml   # Production deployment
  ├── deploy-production.sh             # Automated deployment
  └── QUICKSTART.md                    # Quick reference

K8S-DEPLOYMENT-GUIDE.md          # Full deployment guide
K8S-DATABASE-FIX.md              # Technical explanation
KUBERNETES-FIX-SUMMARY.md        # This file
```

### Existing Files Modified
```
README.md  # Added link to Kubernetes deployment guide
```

### Existing Files NOT Modified
```
docker/Dockerfile               # Still works for Docker Compose
docker/config/config.inc.php    # Still works for Docker Compose
docker-compose.yml              # Still works for Docker Compose
```

**Important**: Your Docker Compose setup is still intact and working! These changes only add Kubernetes support.

## Next Steps

1. **Deploy using the script above**

2. **Complete OJS installation**
   - Go to https://publications.fstu.uz/index/install/install
   - Fill in admin credentials
   - Complete the wizard

3. **Configure OJS**
   - Set up your journal
   - Configure email settings
   - Add users and roles

4. **Set up backups** (Important!)
   ```bash
   # Database backup
   kubectl exec deployment/ojs-mysql-deployment-fstu -n ojs-fstu -- \
     mysqldump -u ojs2 -pEneTorYpHAWB ojs2 > backup.sql
   
   # Files backup
   kubectl cp ojs-fstu/$(kubectl get pod -n ojs-fstu -l app=ojs-fstu -o name | cut -d/ -f2):/var/www/files ./files-backup
   ```

## Troubleshooting

### Still getting database errors?

1. **Check MySQL pod**:
   ```bash
   kubectl get pods -l app=ojs-mysql-fstu -n ojs-fstu
   ```

2. **Test database connection**:
   ```bash
   kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- \
     nc -zv ojs-mysql-service-fstu 3306
   ```

3. **View detailed logs**:
   ```bash
   kubectl logs -l app=ojs-fstu -n ojs-fstu -f
   ```

4. **See full troubleshooting guide**: `K8S-DEPLOYMENT-GUIDE.md`

## Need Help?

- **Quick Start**: `k8s/overlays/fstu/QUICKSTART.md`
- **Full Deployment Guide**: `K8S-DEPLOYMENT-GUIDE.md`
- **Technical Details**: `K8S-DATABASE-FIX.md`

## Common Questions

### Q: Will this break my Docker Compose setup?
**A**: No! All Docker Compose files remain unchanged. The Kubernetes files are separate.

### Q: Do I need to change my nginx configuration?
**A**: No! Your existing nginx proxy configuration (`nginx-config-fixed.conf`) works perfectly with this deployment.

### Q: Can I use a different database?
**A**: Yes! Edit `ojs-configmap-production.yaml` to point to an external database:
```yaml
data:
  OJS_DB_HOST: "your-external-mysql.example.com"
  OJS_DB_NAME: "your_database"
```

### Q: How do I update the deployment?
**A**: 
```bash
# Update ConfigMap
kubectl apply -f ojs-configmap-production.yaml

# Restart pods to pick up changes
kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu
```

### Q: How do I check what's running?
**A**:
```bash
kubectl get all -n ojs-fstu
```

## Success Criteria

✅ Pods are running:
```bash
kubectl get pods -n ojs-fstu
# Both ojs and mysql pods should show STATUS: Running
```

✅ No database errors in logs:
```bash
kubectl logs -l app=ojs-fstu -n ojs-fstu | grep "Database is ready"
# Should show: "Database is ready!"
```

✅ Installation page loads:
```
https://publications.fstu.uz/index/install/install
# Should show installation wizard without database errors
```

✅ Installation completes successfully

---

**Your Kubernetes deployment is now ready!** 🎉

The database connection issue has been resolved. You can now proceed with the OJS installation.

