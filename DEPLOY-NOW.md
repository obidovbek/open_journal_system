# 🚀 Deploy OJS to Kubernetes Now

## The Error You're Seeing

```
❌ SQLSTATE[HY000] [2002] No such file or directory
```

## The Fix (3 Commands)

### 1️⃣ Navigate to deployment directory

```bash
cd /projects/open_journal_system/k8s/overlays/fstu
```

### 2️⃣ Make script executable

```bash
chmod +x deploy-production.sh
```

### 3️⃣ Run deployment

```bash
./deploy-production.sh
```

---

## That's It! ✅

The script will:
- ✅ Build the Kubernetes-specific Docker image
- ✅ Create namespace and resources
- ✅ Deploy MySQL with correct service name
- ✅ Deploy OJS with dynamic configuration
- ✅ Wait for everything to be ready
- ✅ Show deployment status

---

## What You'll See

```
======================================
OJS FSTU Production Deployment
======================================

Step 1: Building Kubernetes-specific OJS image...
✓ Image built successfully

Step 2: Creating namespace...
✓ Namespace created

Step 3: Creating Persistent Volume Claims...
✓ PVCs created

Step 4: Applying ConfigMap and Secrets...
✓ ConfigMap and Secrets applied

Step 5: Deploying MySQL database...
Waiting for MySQL to be ready...
✓ MySQL is ready

Step 6: Deploying OJS application...
Waiting for OJS to be ready...
✓ OJS is ready

Step 7: Applying Ingress...
✓ Ingress applied

======================================
✓ Deployment Complete!
======================================

Next steps:
1. Access OJS installation:
   https://publications.fstu.uz/index/install/install
```

---

## Verify Database Connection

```bash
kubectl logs -l app=ojs-fstu -n ojs-fstu | grep "Database is ready"
```

Expected output:
```
Connection to ojs-mysql-service-fstu 3306 port [tcp/mysql] succeeded!
Database is ready!  ← This means it works! ✅
```

---

## Access OJS

Open your browser and go to:

```
https://publications.fstu.uz/index/install/install
```

**The database error should be gone!** 🎉

---

## If Something Goes Wrong

### Check pod status
```bash
kubectl get pods -n ojs-fstu
```

Both pods should show `Running`:
```
NAME                                          READY   STATUS    RESTARTS   AGE
ojs-deployment-fstu-xxxxx                     1/1     Running   0          2m
ojs-mysql-deployment-fstu-xxxxx               1/1     Running   0          3m
```

### View OJS logs
```bash
kubectl logs -l app=ojs-fstu -n ojs-fstu
```

### View MySQL logs
```bash
kubectl logs -l app=ojs-mysql-fstu -n ojs-fstu
```

### Still having issues?

See the full troubleshooting guide:
- [`KUBERNETES-FIX-SUMMARY.md`](KUBERNETES-FIX-SUMMARY.md)
- [`K8S-DEPLOYMENT-GUIDE.md`](K8S-DEPLOYMENT-GUIDE.md)

---

## Database Credentials

The deployment uses these credentials (from your `env-template.txt`):

- **Host**: `ojs-mysql-service-fstu` (Kubernetes service)
- **Database**: `ojs2`
- **Username**: `ojs2`  
- **Password**: `EneTorYpHAWB`

**Need to change them?** Edit this file before deploying:
```bash
nano k8s/overlays/fstu/ojs-configmap-production.yaml
```

---

## Manual Deployment (Alternative)

If the script doesn't work, deploy manually:

```bash
# 1. Build image
cd /projects/open_journal_system
docker build -f docker/Dockerfile.k8s -t ojs-fstu:k8s ./docker/

# 2. Apply Kubernetes resources
cd k8s/overlays/fstu
kubectl apply -f namespace.yaml
kubectl apply -f ojs-configmap-production.yaml
kubectl apply -f ojs-mysql-deployment.yaml

# Wait for MySQL
kubectl wait --for=condition=ready pod -l app=ojs-mysql-fstu -n ojs-fstu --timeout=300s

# Deploy OJS
kubectl apply -f ojs-deployment-production.yaml

# Wait for OJS
kubectl wait --for=condition=ready pod -l app=ojs-fstu -n ojs-fstu --timeout=300s

# Apply ingress
kubectl apply -f ojs-ingress.yaml
```

---

## Quick Reference

| Command | What it does |
|---------|-------------|
| `kubectl get pods -n ojs-fstu` | Check if pods are running |
| `kubectl logs -l app=ojs-fstu -n ojs-fstu -f` | View OJS logs (live) |
| `kubectl get all -n ojs-fstu` | View all resources |
| `kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu` | Restart OJS |
| `kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- sh` | Shell into OJS pod |

---

## Success Checklist

After running the deployment:

- [ ] Both pods show `Running` status
- [ ] OJS logs show "Database is ready!"
- [ ] Installation page loads without errors
- [ ] No database connection errors
- [ ] Installation wizard works properly

---

## Need More Info?

- **Quick overview**: [`KUBERNETES-FIX-SUMMARY.md`](KUBERNETES-FIX-SUMMARY.md)
- **Complete guide**: [`K8S-DEPLOYMENT-GUIDE.md`](K8S-DEPLOYMENT-GUIDE.md)
- **All documentation**: [`INDEX.md`](INDEX.md)

---

**Ready? Run the 3 commands at the top of this file!** 🚀

