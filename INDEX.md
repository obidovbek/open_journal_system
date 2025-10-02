# OJS Documentation Index

## 🚨 Start Here - Kubernetes Database Error Fix

If you're seeing **database connection errors** in Kubernetes:

**→ Read**: [`KUBERNETES-FIX-SUMMARY.md`](KUBERNETES-FIX-SUMMARY.md)  
**→ Deploy**: Run `k8s/overlays/fstu/deploy-production.sh`

---

## 📚 Documentation by Topic

### Kubernetes Deployment (Production)

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [`KUBERNETES-FIX-SUMMARY.md`](KUBERNETES-FIX-SUMMARY.md) | **START HERE** - Overview of the database fix | First time deploying to K8s |
| [`k8s/overlays/fstu/QUICKSTART.md`](k8s/overlays/fstu/QUICKSTART.md) | 3-step deployment guide | Want to deploy quickly |
| [`K8S-DEPLOYMENT-GUIDE.md`](K8S-DEPLOYMENT-GUIDE.md) | Complete K8s deployment guide | Need detailed instructions |
| [`K8S-DATABASE-FIX.md`](K8S-DATABASE-FIX.md) | Technical explanation of the fix | Want to understand how it works |

### Docker Compose Deployment (Development)

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [`README.md`](README.md) | Docker Compose setup guide | Local development/testing |
| [`env-template.txt`](env-template.txt) | Environment variables template | Setting up .env file |

### Troubleshooting Guides

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [`README-HTTPS-FIX.md`](README-HTTPS-FIX.md) | HTTPS mixed content fix | Seeing HTTP/HTTPS errors |
| [`REDIRECT-LOOP-FIX.md`](REDIRECT-LOOP-FIX.md) | Redirect loop fix | Getting ERR_TOO_MANY_REDIRECTS |

### Configuration Examples

| File | Purpose | When to Use |
|------|---------|-------------|
| [`nginx-config-example.conf`](nginx-config-example.conf) | Nginx proxy config example | Setting up nginx proxy |
| [`nginx-config-fixed.conf`](nginx-config-fixed.conf) | Fixed nginx config (no loops) | If experiencing redirect issues |

---

## 🎯 Quick Navigation

### I want to...

**Deploy OJS to Kubernetes for production**
1. Read: [`KUBERNETES-FIX-SUMMARY.md`](KUBERNETES-FIX-SUMMARY.md)
2. Run: `k8s/overlays/fstu/deploy-production.sh`
3. Access: https://publications.fstu.uz/index/install/install

**Deploy OJS locally with Docker Compose**
1. Read: [`README.md`](README.md)
2. Run: `docker-compose up -d`
3. Access: http://localhost:8081

**Fix database connection error in Kubernetes**
→ [`K8S-DATABASE-FIX.md`](K8S-DATABASE-FIX.md)

**Fix HTTPS mixed content errors**
→ [`README-HTTPS-FIX.md`](README-HTTPS-FIX.md)

**Fix redirect loops (ERR_TOO_MANY_REDIRECTS)**
→ [`REDIRECT-LOOP-FIX.md`](REDIRECT-LOOP-FIX.md)

**Understand how the Kubernetes fix works**
→ [`K8S-DATABASE-FIX.md`](K8S-DATABASE-FIX.md)

**Troubleshoot my Kubernetes deployment**
→ [`K8S-DEPLOYMENT-GUIDE.md`](K8S-DEPLOYMENT-GUIDE.md) - Troubleshooting section

---

## 📂 Project Structure

```
open_journal_system/
├── 📘 README.md                          # Docker Compose guide
├── 📘 KUBERNETES-FIX-SUMMARY.md          # K8s fix overview (START HERE)
├── 📘 K8S-DEPLOYMENT-GUIDE.md            # Complete K8s guide
├── 📘 K8S-DATABASE-FIX.md                # Technical details
├── 📘 README-HTTPS-FIX.md                # HTTPS troubleshooting
├── 📘 REDIRECT-LOOP-FIX.md               # Redirect troubleshooting
├── 📘 INDEX.md                           # This file
│
├── docker/
│   ├── Dockerfile                        # Docker Compose image
│   ├── Dockerfile.k8s                    # Kubernetes image (NEW)
│   ├── entrypoint-k8s.sh                 # K8s startup script (NEW)
│   ├── apache-https.conf                 # Apache HTTPS config
│   ├── https_forwarded.php               # HTTPS detection
│   ├── .user.ini                         # PHP settings
│   └── config/
│       ├── config.inc.php                # Docker Compose config
│       └── config.inc.k8s.php            # K8s config template
│
├── k8s/
│   ├── ingressclass-traefik.yaml         # Traefik ingress class
│   └── overlays/fstu/
│       ├── 📘 QUICKSTART.md              # Quick deployment guide
│       ├── 📘 README.md                  # Original K8s notes
│       ├── 🚀 deploy-production.sh       # Deployment script (RUN THIS)
│       ├── namespace.yaml                # Namespace definition
│       ├── ojs-configmap-production.yaml # Production config (NEW)
│       ├── ojs-deployment-production.yaml# Production deployment (NEW)
│       ├── ojs-mysql-deployment.yaml     # MySQL deployment
│       ├── ojs-ingress.yaml              # Ingress rules
│       └── ojs-pvc-fixed.yaml            # Storage claims
│
├── data/                                 # Persistent data (auto-created)
│   ├── mysql/                            # MySQL data
│   ├── ojs_files/                        # OJS uploads
│   └── ojs_public/                       # Public files
│
├── docker-compose.yml                    # Docker Compose config
├── env-template.txt                      # Environment template
├── nginx-config-example.conf             # Nginx config example
└── nginx-config-fixed.conf               # Fixed nginx config
```

---

## 🔧 Deployment Scripts

### Kubernetes

```bash
# Main deployment script (recommended)
k8s/overlays/fstu/deploy-production.sh

# Other scripts
k8s/overlays/fstu/deploy-ojs.sh         # Alternative deployment
k8s/overlays/fstu/deploy-ojs-fixed.sh   # Fixed version
k8s/overlays/fstu/diagnose-and-fix.sh   # Diagnostic tool
```

---

## 📋 Common Tasks

### Kubernetes Commands

```bash
# Deploy to Kubernetes
cd k8s/overlays/fstu && ./deploy-production.sh

# View pods
kubectl get pods -n ojs-fstu

# View logs
kubectl logs -l app=ojs-fstu -n ojs-fstu -f

# Restart deployment
kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu

# Shell into pod
kubectl exec -it deployment/ojs-deployment-fstu -n ojs-fstu -- sh

# View all resources
kubectl get all -n ojs-fstu
```

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f ojs

# Restart OJS
docker-compose restart ojs

# Rebuild and restart
docker-compose down
docker-compose build --no-cache ojs
docker-compose up -d

# View status
docker-compose ps
```

---

## ❓ FAQ

### Which deployment should I use?

- **Kubernetes**: Production deployment (recommended for publications.fstu.uz)
- **Docker Compose**: Development, testing, or simple single-server deployment

### Do I need to change my nginx config?

No! Your existing nginx configuration works with both deployments.

### Will Kubernetes deployment affect Docker Compose?

No! They're completely separate. Docker Compose continues to work as before.

### Where are my database credentials?

- **Docker Compose**: `.env` file (copy from `env-template.txt`)
- **Kubernetes**: `k8s/overlays/fstu/ojs-configmap-production.yaml`

### How do I update configuration?

**Kubernetes**:
```bash
# Edit config
kubectl edit configmap ojs-fstu-config -n ojs-fstu
# Restart pods
kubectl rollout restart deployment/ojs-deployment-fstu -n ojs-fstu
```

**Docker Compose**:
```bash
# Edit .env file
nano .env
# Restart services
docker-compose restart ojs
```

---

## 🆘 Getting Help

### Check Logs

**Kubernetes**:
```bash
kubectl logs -l app=ojs-fstu -n ojs-fstu --tail=50
```

**Docker Compose**:
```bash
docker-compose logs ojs --tail=50
```

### Common Issues

| Error | Document |
|-------|----------|
| Database connection error | [`K8S-DATABASE-FIX.md`](K8S-DATABASE-FIX.md) |
| Mixed content (HTTP/HTTPS) | [`README-HTTPS-FIX.md`](README-HTTPS-FIX.md) |
| Redirect loops | [`REDIRECT-LOOP-FIX.md`](REDIRECT-LOOP-FIX.md) |
| General troubleshooting | [`K8S-DEPLOYMENT-GUIDE.md`](K8S-DEPLOYMENT-GUIDE.md) |

### External Resources

- [OJS Documentation](https://docs.pkp.sfu.ca/)
- [PKP Support Forum](https://forum.pkp.sfu.ca/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

## ✅ Checklist

### First-Time Kubernetes Deployment

- [ ] Read [`KUBERNETES-FIX-SUMMARY.md`](KUBERNETES-FIX-SUMMARY.md)
- [ ] Review database credentials in `ojs-configmap-production.yaml`
- [ ] Run `k8s/overlays/fstu/deploy-production.sh`
- [ ] Check pods: `kubectl get pods -n ojs-fstu`
- [ ] Check logs: `kubectl logs -l app=ojs-fstu -n ojs-fstu`
- [ ] Access: https://publications.fstu.uz/index/install/install
- [ ] Complete OJS installation wizard
- [ ] Set up backups
- [ ] Configure email settings

### First-Time Docker Compose Deployment

- [ ] Read [`README.md`](README.md)
- [ ] Copy `env-template.txt` to `.env`
- [ ] Edit `.env` with your passwords
- [ ] Run `docker-compose up -d`
- [ ] Check logs: `docker-compose logs -f ojs`
- [ ] Access: http://localhost:8081
- [ ] Complete OJS installation wizard

---

**Last Updated**: 2024-10-02

**Questions?** Check the relevant guide above or see the troubleshooting sections.

