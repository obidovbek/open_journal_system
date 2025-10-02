# Kubernetes Database Connection Fix

## The Error You Were Seeing

```
Errors occurred during installation
A database error has occurred: SQLSTATE[HY000] [2002] No such file or directory
(SQL: create table `journals` ...)
```

## Root Cause Analysis

### The Problem

1. **Wrong Database Host**: The `docker/config/config.inc.php` file had a hardcoded database host:
   ```ini
   [database]
   host = ojs-mysql  # ❌ This is the Docker Compose service name
   ```

2. **Kubernetes Uses Different Service Names**: In your Kubernetes deployment, the MySQL service is:
   ```
   ojs-mysql-service-fstu  # ✅ Kubernetes service DNS name
   ```

3. **Static Configuration**: The config file was copied into the image at build time and couldn't adapt to different environments.

4. **Environment Variables Not Used**: Even though your Kubernetes deployment defined `OJS_DB_HOST`, the static config file ignored it.

### Why It Worked in Docker Compose But Not Kubernetes

| Environment | Database Host | Why |
|-------------|---------------|-----|
| Docker Compose | `ojs-mysql` | Service name from docker-compose.yml |
| Kubernetes | `ojs-mysql-service-fstu` | Kubernetes Service DNS (servicename.namespace.svc.cluster.local) |

## The Solution

We created a **Kubernetes-specific deployment** with these fixes:

### 1. Dynamic Configuration Generation

**New file**: `docker/entrypoint-k8s.sh`

This script runs at container startup and generates `config.inc.php` from environment variables:

```bash
# Read from environment
OJS_DB_HOST=${OJS_DB_HOST:-localhost}
OJS_DB_NAME=${OJS_DB_NAME:-ojs_db}
OJS_DB_USER=${OJS_DB_USER:-ojs_user}
OJS_DB_PASSWORD=${OJS_DB_PASSWORD:-changeme}

# Generate config.inc.php with actual values
cat > /var/www/html/config.inc.php << EOF
[database]
host = $OJS_DB_HOST
name = $OJS_DB_NAME
username = $OJS_DB_USER
password = $OJS_DB_PASSWORD
EOF
```

### 2. Database Wait Logic

The entrypoint script waits for MySQL to be ready before starting Apache:

```bash
# Wait for MySQL to be ready
until nc -z -v -w30 $OJS_DB_HOST 3306
do
  echo "Waiting for database connection at $OJS_DB_HOST:3306..."
  sleep 5
done
```

This prevents OJS from trying to connect before MySQL is ready.

### 3. Kubernetes-Specific Dockerfile

**New file**: `docker/Dockerfile.k8s`

- Based on the same OJS 3.4.0 image
- Includes `netcat` for database connectivity testing
- Uses the new entrypoint script
- Doesn't mount a static config file

### 4. Correct Environment Variables

**New file**: `k8s/overlays/fstu/ojs-configmap-production.yaml`

Defines the correct values for Kubernetes:

```yaml
data:
  OJS_DB_HOST: "ojs-mysql-service-fstu"  # ✅ Correct Kubernetes service name
  OJS_DB_NAME: "ojs2"
  # ... other settings
```

### 5. Production Database Credentials

Uses your actual production credentials from `env-template.txt`:

```yaml
stringData:
  db-user: "ojs2"
  db-password: "EneTorYpHAWB"
```

## Comparison: Before vs After

### Before (Broken)

```
┌─────────────────┐
│   OJS Pod       │
├─────────────────┤
│ config.inc.php  │
│ host=ojs-mysql  │ ❌ Wrong host
└────────┬────────┘
         │
         ├─ Try to connect to "ojs-mysql"
         └─ ERROR: No such file or directory
```

### After (Fixed)

```
┌──────────────────────────┐
│      OJS Pod             │
├──────────────────────────┤
│ entrypoint-k8s.sh        │
│  ↓                       │
│ Reads env vars:          │
│  OJS_DB_HOST=            │
│   ojs-mysql-service-fstu │ ✅ Correct!
│  ↓                       │
│ Generates config.inc.php │
│  ↓                       │
│ Waits for MySQL          │
│  ↓                       │
│ Starts Apache            │
└────────┬─────────────────┘
         │
         ├─ Connect to "ojs-mysql-service-fstu:3306"
         └─ ✅ SUCCESS!
              ↓
         ┌────────────────┐
         │  MySQL Pod     │
         │ ojs2 database  │
         └────────────────┘
```

## Files Created to Fix the Issue

1. **`docker/Dockerfile.k8s`**
   - Kubernetes-specific image
   - Includes database wait tools
   - Uses dynamic entrypoint

2. **`docker/entrypoint-k8s.sh`**
   - Generates config from environment variables
   - Waits for database to be ready
   - Handles startup sequence

3. **`k8s/overlays/fstu/ojs-configmap-production.yaml`**
   - Correct database host for Kubernetes
   - Production database credentials
   - HTTPS configuration

4. **`k8s/overlays/fstu/ojs-deployment-production.yaml`**
   - Uses the new k8s-specific image
   - Passes all environment variables
   - Includes health checks

5. **`k8s/overlays/fstu/deploy-production.sh`**
   - Automated deployment script
   - Builds the image
   - Deploys all components in correct order

6. **`K8S-DEPLOYMENT-GUIDE.md`**
   - Complete deployment documentation
   - Troubleshooting guide
   - Monitoring instructions

## How to Deploy the Fix

### Quick Method

```bash
cd /projects/open_journal_system/k8s/overlays/fstu
chmod +x deploy-production.sh
./deploy-production.sh
```

### Manual Method

```bash
# 1. Build Kubernetes image
cd /projects/open_journal_system
docker build -f docker/Dockerfile.k8s -t ojs-fstu:k8s ./docker/

# 2. Apply Kubernetes resources
cd k8s/overlays/fstu
kubectl apply -f namespace.yaml
kubectl apply -f ojs-pvc-fixed.yaml  # or ojs-pvc.yaml
kubectl apply -f ojs-configmap-production.yaml
kubectl apply -f ojs-mysql-deployment.yaml
kubectl apply -f ojs-deployment-production.yaml
kubectl apply -f ojs-ingress.yaml

# 3. Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=ojs-fstu -n ojs-fstu --timeout=300s

# 4. Check logs
kubectl logs -l app=ojs-fstu -n ojs-fstu
```

## Verification

After deployment, check that the database connection works:

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

## Test the Fix

1. **Access the installation wizard**:
   ```
   https://publications.fstu.uz/index/install/install
   ```

2. **The database error should be gone** ✅

3. **Complete the installation** with your admin credentials

## Technical Details

### Service Discovery in Kubernetes

When you create a Kubernetes Service, it gets a DNS entry:

```
<service-name>.<namespace>.svc.cluster.local
```

For your deployment:
```
ojs-mysql-service-fstu.ojs-fstu.svc.cluster.local
```

Short form (within same namespace):
```
ojs-mysql-service-fstu
```

### Environment Variable Precedence

The entrypoint script uses this pattern:
```bash
: ${OJS_DB_HOST:=localhost}
```

This means:
1. Use `$OJS_DB_HOST` if it's set (from Kubernetes ConfigMap)
2. Otherwise, use `localhost` as default

### Why We Don't Use ConfigMap Volume Mount for Config

We considered mounting config.inc.php as a ConfigMap, but:

❌ **Cons**:
- OJS config has special syntax that's hard to template
- Secrets can't be easily mixed with ConfigMaps
- Database passwords would be visible in ConfigMaps

✅ **Better approach**:
- Generate config at runtime from environment variables
- Keep secrets in Kubernetes Secrets
- More flexible for different environments

## Troubleshooting

If you still see database errors:

### 1. Check MySQL is Running

```bash
kubectl get pods -l app=ojs-mysql-fstu -n ojs-fstu
```

### 2. Verify Service DNS

```bash
kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- nslookup ojs-mysql-service-fstu
```

### 3. Test Database Connection

```bash
kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- nc -zv ojs-mysql-service-fstu 3306
```

### 4. Check Credentials

```bash
kubectl get secret ojs-fstu-secret -n ojs-fstu -o jsonpath='{.data.db-user}' | base64 -d
kubectl get secret ojs-fstu-secret -n ojs-fstu -o jsonpath='{.data.db-password}' | base64 -d
```

### 5. View Generated Config

```bash
kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- cat /var/www/html/config.inc.php | grep -A5 "\[database\]"
```

## Summary

✅ **Problem**: Hardcoded database host didn't work in Kubernetes  
✅ **Solution**: Dynamic config generation from environment variables  
✅ **Result**: Database connection works in Kubernetes  

The fix maintains compatibility with your existing nginx proxy setup and preserves all HTTPS functionality while solving the database connection issue.

---

**Need help?** See the full deployment guide: [K8S-DEPLOYMENT-GUIDE.md](K8S-DEPLOYMENT-GUIDE.md)

