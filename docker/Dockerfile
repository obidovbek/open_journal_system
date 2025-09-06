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
RUN cat > /docker-entrypoint.sh << 'EOF'
#!/bin/sh
set -e

# Substitute environment variables in config template
envsubst < /var/www/html/config.inc.php.template > /var/www/html/config.inc.php

# Set proper permissions
chmod 644 /var/www/html/config.inc.php
chown www-data:www-data /var/www/html/config.inc.php

# Ensure directories exist and have proper permissions
mkdir -p /var/www/files /var/www/html/public /var/www/html/cache
chown -R www-data:www-data /var/www/files /var/www/html/public /var/www/html/cache
chmod -R 755 /var/www/files /var/www/html/public /var/www/html/cache

# Set Apache environment variables for HTTPS
export HTTPS=on
export SERVER_NAME=${SERVER_NAME:-publications.fstu.uz}

# Start Apache in foreground
exec apache2-foreground
EOF

RUN chmod +x /docker-entrypoint.sh

# Expose port
EXPOSE 80

# Use custom entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"] 