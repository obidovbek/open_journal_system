# Open Journal System (OJS) for FSTU

This directory contains the complete Open Journal System (OJS) setup for Ferghana State Technical University, configured to run at `https://publications.fstu.uz`.

## 🏗 Directory Structure

```
open_journal_system/
├── docker/                     # Docker configuration
│   ├── Dockerfile             # OJS container definition
│   └── config/
│       └── config.inc.php     # OJS application configuration
├── k8s/                       # Kubernetes configurations
│   ├── base/                  # Base Kubernetes resources
│   │   ├── ojs-deployment.yaml
│   │   ├── ojs-mysql-deployment.yaml
│   │   ├── persistent-volumes.yaml
│   │   ├── configmaps-secrets.yaml
│   │   └── ingress.yaml
│   └── overlays/              # Environment-specific overrides
│       ├── demo/              # Demo environment
│       └── fstu/              # FSTU production environment
├── data/                      # Local data storage (Docker)
│   ├── mysql/                 # MySQL data
│   ├── ojs_files/            # OJS uploaded files
│   └── ojs_public/           # OJS public files
├── docker-compose.yml         # Standalone Docker Compose
├── .env.example              # Environment template
└── README.md                 # This file
```

## 🚀 Quick Start

### Docker Development Setup

1. **Configure Environment**:

   ```bash
   cd open_journal_system
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Start OJS**:

   ```bash
   docker-compose up -d
   ```

3. **Access OJS**:
   - URL: http://localhost:8081
   - Complete the web-based installation wizard

### Kubernetes Production Deployment (FSTU)

1. **Deploy to FSTU Environment**:

   ```bash
   cd k8s/overlays/fstu
   chmod +x deploy-ojs.sh
   ./deploy-ojs.sh
   ```

2. **Update Main FSTU Ingress**:
   Add the following to your main FSTU ingress configuration:

   ```yaml
   - host: publications.fstu.uz
     http:
       paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: ojs-service-fstu
               port:
                 number: 80
   ```

3. **Access Production OJS**:
   - URL: https://publications.fstu.uz

## ⚙️ Configuration

### OJS Configuration

The main OJS configuration is in `docker/config/config.inc.php`. Key settings:

- **Database**: MySQL 8.0 with dedicated database
- **Base URL**: https://publications.fstu.uz
- **File Storage**: Persistent volumes for uploads and public files
- **Locale**: English (US) by default
- **Security**: SHA1 encryption with configurable salt

### Environment Variables

| Variable                  | Description         | Default                        |
| ------------------------- | ------------------- | ------------------------------ |
| `OJS_DB_NAME`             | Database name       | `ojs_db`                       |
| `OJS_DB_USER`             | Database user       | `ojs_user`                     |
| `OJS_DB_PASSWORD`         | Database password   | Required                       |
| `OJS_MYSQL_ROOT_PASSWORD` | MySQL root password | Required                       |
| `OJS_BASE_URL`            | OJS base URL        | `https://publications.fstu.uz` |

### Kubernetes Secrets

For production, update the base64-encoded secrets in `k8s/overlays/fstu/ojs-configmap.yaml`:

```bash
# Generate new secrets
echo -n 'your_actual_db_user' | base64
echo -n 'your_actual_db_password' | base64
echo -n 'your_actual_root_password' | base64
```

## 💾 Data Storage

### Docker Volumes

- `./data/mysql`: MySQL database files
- `./data/ojs_files`: OJS uploaded files
- `./data/ojs_public`: OJS public files

### Kubernetes Persistent Volumes

- `ojs-files-fstu-pvc`: 10Gi for uploaded files
- `ojs-public-fstu-pvc`: 5Gi for public files
- `ojs-mysql-fstu-pvc`: 20Gi for database

## 🔧 Management Commands

### Docker Commands

```bash
# Start OJS
docker-compose up -d

# Stop OJS
docker-compose down

# View logs
docker-compose logs -f ojs
docker-compose logs -f ojs-mysql

# Access OJS container
docker exec -it ojs bash

# Access MySQL
docker exec -it ojs-mysql mysql -u ojs_user -p
```

### Kubernetes Commands

```bash
# Check deployment status
kubectl get pods -l app=ojs-fstu -n fstu

# View logs
kubectl logs -f deployment/ojs-deployment-fstu -n fstu

# Access OJS pod
kubectl exec -it deployment/ojs-deployment-fstu -n fstu -- bash

# Port forward for testing
kubectl port-forward service/ojs-service-fstu 8081:80 -n fstu
```

## 🛡 Security Considerations

1. **Database Passwords**: Use strong, unique passwords
2. **OJS Salt**: Generate a unique salt value for production
3. **SSL/TLS**: Ensure HTTPS is properly configured
4. **File Permissions**: Verify proper file permissions in containers
5. **Regular Updates**: Keep OJS and MySQL updated

## 📚 OJS Administration

### Initial Setup

1. Access OJS web interface
2. Run the installation wizard
3. Create administrator account
4. Configure journal settings
5. Set up editorial workflow

### Key Administrative Tasks

- **Journal Management**: Create and configure journals
- **User Management**: Manage authors, reviewers, editors
- **Submission Workflow**: Configure peer review process
- **Theme Customization**: Customize appearance
- **Plugin Management**: Install and configure plugins

## 🔄 Backup and Recovery

### Database Backup

```bash
# Docker
docker exec ojs-mysql mysqldump -u root -p ojs_db > ojs_backup.sql

# Kubernetes
kubectl exec deployment/ojs-mysql-deployment-fstu -n fstu -- mysqldump -u root -p ojs_fstu_db > ojs_backup.sql
```

### File Backup

```bash
# Docker
tar -czf ojs_files_backup.tar.gz ./data/

# Kubernetes - copy from pod
kubectl cp fstu/ojs-deployment-fstu-xxx:/var/www/files ./ojs_files_backup/
```

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Failed**

   - Check MySQL service is running
   - Verify credentials in environment/secrets
   - Ensure network connectivity

2. **File Upload Issues**

   - Check volume permissions
   - Verify storage space
   - Review PHP upload limits

3. **Email Not Working**
   - Configure SMTP settings
   - Check firewall rules
   - Verify DNS configuration

### Debug Mode

Enable debug mode by setting in `config.inc.php`:

```php
show_stacktrace = On
log_errors = On
```

## 📞 Support

- **OJS Documentation**: https://docs.pkp.sfu.ca/ojs/
- **OJS Community Forum**: https://forum.pkp.sfu.ca/
- **Technical Issues**: Contact your system administrator

## 🔄 Upgrade Path

### OJS Version Updates

1. Backup database and files
2. Update Docker image version in `docker/Dockerfile`
3. Rebuild and redeploy containers
4. Run OJS upgrade wizard through web interface
5. Test functionality thoroughly

### Kubernetes Updates

1. Update image tags in deployment files
2. Apply updated configurations
3. Monitor deployment rollout
4. Verify service functionality
