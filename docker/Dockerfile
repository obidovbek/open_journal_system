FROM pkpofficial/ojs:3_4_0-5

# Set working directory
WORKDIR /var/www/html

# Install additional packages if needed (Alpine Linux uses apk)
RUN apk update && apk add --no-cache \
    curl \
    zip \
    unzip \
    envsubst

# Copy custom configuration
COPY config/config.inc.php /var/www/html/config.inc.php.template

# Create entrypoint script to handle environment variable substitution
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'set -e' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Get the actual web server user' >> /docker-entrypoint.sh && \
    echo 'WEB_USER=$(grep "^www-data:" /etc/passwd | cut -d: -f1 || echo "apache")' >> /docker-entrypoint.sh && \
    echo 'WEB_GROUP=$(grep "^www-data:" /etc/group | cut -d: -f1 || echo "apache")' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Substitute environment variables in config template' >> /docker-entrypoint.sh && \
    echo 'if [ -f /var/www/html/config.inc.php.template ]; then' >> /docker-entrypoint.sh && \
    echo '  envsubst < /var/www/html/config.inc.php.template > /var/www/html/config.inc.php' >> /docker-entrypoint.sh && \
    echo '  chmod 644 /var/www/html/config.inc.php' >> /docker-entrypoint.sh && \
    echo '  if [ "$WEB_USER" != "" ]; then' >> /docker-entrypoint.sh && \
    echo '    chown $WEB_USER:$WEB_GROUP /var/www/html/config.inc.php' >> /docker-entrypoint.sh && \
    echo '  fi' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Ensure directories exist and have proper permissions' >> /docker-entrypoint.sh && \
    echo 'mkdir -p /var/www/files /var/www/html/public /var/www/html/cache' >> /docker-entrypoint.sh && \
    echo 'chmod -R 755 /var/www/files /var/www/html/public /var/www/html/cache' >> /docker-entrypoint.sh && \
    echo 'if [ "$WEB_USER" != "" ]; then' >> /docker-entrypoint.sh && \
    echo '  chown -R $WEB_USER:$WEB_GROUP /var/www/files /var/www/html/public /var/www/html/cache 2>/dev/null || true' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Set Apache environment variables for HTTPS' >> /docker-entrypoint.sh && \
    echo 'export HTTPS=on' >> /docker-entrypoint.sh && \
    echo 'export SERVER_NAME=${SERVER_NAME:-publications.fstu.uz}' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Start Apache in foreground' >> /docker-entrypoint.sh && \
    echo 'exec apache2-foreground' >> /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

# Expose port
EXPOSE 80

# Use custom entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"] 