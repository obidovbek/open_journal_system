# OJS Kubernetes Quick Start

## The Problem You Had

```
SQLSTATE[HY000] [2002] No such file or directory
```

This error occurred because the database host was hardcoded as `ojs-mysql` (Docker name) instead of `ojs-mysql-service-fstu` (Kubernetes service name).

## The Fix

We've created a Kubernetes-specific deployment that:
1. Generates `config.inc.php` dynamically from environment variables
2. Uses the correct Kubernetes service DNS name for MySQL
3. Waits for the database to be ready before starting
4. Uses your production database credentials

## Deploy in 3 Steps

### 1. Navigate to the directory

```bash
cd /projects/open_journal_system/k8s/overlays/fstu
```

### 2. Run the deployment script

```bash
chmod +x deploy-production.sh
./deploy-production.sh
```

### 3. Access OJS

```
https://publications.fstu.uz/index/install/install
```

The database error should be resolved! ✅

## Verify It's Working

Check the logs to confirm database connection:

```bash
kubectl logs -l app=ojs-fstu -n ojs-fstu | grep "Database is ready"
```

You should see:
```
Connection to ojs-mysql-service-fstu 3306 port [tcp/mysql] succeeded!
Database is ready!
```

## Common Commands

```bash
# View pods
kubectl get pods -n ojs-fstu

# View logs
kubectl logs -l app=ojs-fstu -n ojs-fstu -f

# Restart OJS
kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu

# Shell into OJS
kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- sh

# Connect to database
kubectl exec -it deployment/ojs-mysql-deployment-fstu -n ojs-fstu -- mysql -u ojs2 -p
```

## Need More Help?

See the full deployment guide: `K8S-DEPLOYMENT-GUIDE.md`

## Database Credentials Used

The deployment uses these credentials from your `env-template.txt`:

- **Host**: `ojs-mysql-service-fstu` (Kubernetes service)
- **Database**: `ojs2`
- **Username**: `ojs2`
- **Password**: `EneTorYpHAWB`

To change these, edit `ojs-configmap-production.yaml` before deploying.

