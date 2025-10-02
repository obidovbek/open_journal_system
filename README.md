# Open Journal System (OJS) with HTTPS Proxy Support

This project sets up Open Journal Systems (OJS) 3.4.0 with proper HTTPS support behind an nginx reverse proxy.

## 📦 Deployment Options

> **📘 New to this project?** See [INDEX.md](INDEX.md) for a complete documentation guide.

- **Docker Compose**: See instructions below (development/testing)
- **Kubernetes**: See [KUBERNETES-FIX-SUMMARY.md](KUBERNETES-FIX-SUMMARY.md) to fix database connection errors
  - Quick Start: [k8s/overlays/fstu/QUICKSTART.md](k8s/overlays/fstu/QUICKSTART.md)
  - Full Guide: [K8S-DEPLOYMENT-GUIDE.md](K8S-DEPLOYMENT-GUIDE.md)

## 🚨 HTTPS Proxy Solution

If you're experiencing mixed content errors (HTTP resources loaded on HTTPS pages), this setup includes:

1. **Proper HTTPS Detection**: OJS automatically detects when it's behind an HTTPS proxy
2. **Force SSL Configuration**: All URLs are generated as HTTPS
3. **Proxy Header Trust**: Trusts X-Forwarded-Proto and X-Forwarded-Port headers
4. **Secure Cookies**: Forces secure cookies when using HTTPS

### Fixed Issues:

- ✅ Mixed Content errors (CSS/JS loaded over HTTP)
- ✅ Form actions pointing to HTTP instead of HTTPS
- ✅ JavaScript libraries not loading due to protocol mismatch
- ✅ Login and admin panels working properly over HTTPS

## 🔧 Nginx Proxy Configuration

Your nginx configuration should include these headers (which you already have):

```nginx
proxy_set_header X-Forwarded-Proto https;
proxy_set_header X-Forwarded-Port 443;
proxy_set_header Host $http_host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## 🚀 Quick Deployment

1. **Create environment file:**

   ```bash
   cp env-template.txt .env
   # Edit .env with your actual database passwords
   ```

2. **Deploy with HTTPS support:**

   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   Or manually:

   ```bash
   docker-compose down
   docker-compose build --no-cache ojs
   docker-compose up -d
   ```

3. **Monitor logs:**
   ```bash
   docker-compose logs -f ojs
   ```

## 📋 Environment Configuration

Update your `.env` file with these settings:

```env
# Database settings
OJS_DB_NAME=ojs_db
OJS_DB_USER=ojs_user
OJS_DB_PASSWORD=your_secure_password
OJS_MYSQL_ROOT_PASSWORD=your_root_password

# HTTPS Configuration - CRITICAL for proxy setup
OJS_BASE_URL=https://publications.fstu.uz

# Email settings
OJS_DEFAULT_ENVELOPE_SENDER=noreply@fstu.uz
```

## 🔍 Key Configuration Changes

### 1. OJS Configuration (`docker/config/config.inc.php`)

- `force_ssl = On` - Forces all URLs to use HTTPS
- `trusted_proxies` - Trusts proxy headers from your network
- `force_login_ssl = On` - Forces secure login
- `proxy_x_forwarded_for = On` - Detects real client IP

### 2. Docker Environment

- `HTTPS=on` - Tells PHP it's running under HTTPS
- `HTTP_X_FORWARDED_PROTO=https` - Protocol detection
- `HTTP_X_FORWARDED_PORT=443` - Port detection

### 3. PHP Proxy Setup

- Automatic detection of proxy headers
- Sets `$_SERVER['HTTPS']` when behind HTTPS proxy
- Proper port detection for URL generation

## 🛠️ Troubleshooting

### Mixed Content Errors Still Appearing?

1. **Check nginx proxy headers** - Ensure X-Forwarded-Proto is set to "https"
2. **Clear browser cache** - Hard refresh or try incognito mode
3. **Verify base URL** - Check OJS admin settings match your domain
4. **Check logs** - `docker-compose logs ojs`

### Database Connection Issues?

1. **Wait for MySQL** - Database takes time to initialize on first run
2. **Check passwords** - Verify .env file has correct credentials
3. **Reset database** - `docker-compose down -v` (WARNING: deletes data)

### Performance Issues?

1. **Enable caching** - OJS has built-in file caching enabled
2. **Monitor resources** - `docker stats`
3. **Check disk space** - Ensure adequate space for uploads

## 📊 Service Status

Check if services are running:

```bash
docker-compose ps
docker-compose logs --tail=50 ojs
```

## 🔐 Security Considerations

- Change default passwords in `.env`
- Use strong database passwords
- Keep OJS updated to latest security patches
- Monitor nginx access logs for suspicious activity
- Consider rate limiting in nginx for login endpoints

## 📁 Directory Structure

```
open_journal_system/
├── docker/
│   ├── Dockerfile          # Custom OJS image with HTTPS support
│   └── config/
│       └── config.inc.php  # OJS configuration with proxy settings
├── data/                   # Persistent data (auto-created)
├── k8s/                    # Kubernetes deployment files
├── docker-compose.yml      # Service orchestration
├── deploy.sh              # Deployment script
├── .env                   # Environment configuration
└── README.md              # This file
```

## 🌐 Access Your Installation

After deployment, access your OJS at:

- **Public Site**: https://publications.fstu.uz
- **Admin Interface**: https://publications.fstu.uz/index/admin

Default admin credentials are set during the OJS installation wizard.

## 📞 Support

If you continue to experience issues:

1. Check the deployment logs: `docker-compose logs ojs`
2. Verify nginx proxy configuration
3. Test with curl: `curl -I https://publications.fstu.uz`
4. Check OJS admin settings for correct base URL

---

_This configuration has been tested with OJS 3.4.0 behind nginx reverse proxy with SSL termination._
