FROM pkpofficial/ojs:3_4_0-5
WORKDIR /var/www/html

# Install required packages
RUN apk update && apk add --no-cache curl zip unzip

# Enable Apache modules (only if not already loaded)
RUN sed -i 's/^#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule headers_module/LoadModule headers_module/' /etc/apache2/httpd.conf && \
    sed -i 's/^#LoadModule setenvif_module/LoadModule setenvif_module/' /etc/apache2/httpd.conf

# Copy OJS configuration directory
COPY config/ /var/www/html/config/

# Copy main OJS configuration file to root
COPY config/config.inc.php /var/www/html/config.inc.php

# Add HTTPS detection to .htaccess
RUN printf "\n# Trust reverse proxy HTTPS headers\nSetEnvIf X-Forwarded-Proto \"https\" HTTPS=on\nSetEnvIf X-Forwarded-Port \"443\" SERVER_PORT=443\n" >> /var/www/html/.htaccess

# Copy PHP auto-prepend for HTTPS detection
COPY https_forwarded.php /var/www/html/https_forwarded.php
COPY .user.ini /var/www/html/.user.ini

# Copy Apache configuration for proxy and logging
COPY apache-https-no-tls.conf /etc/apache2/conf.d/zzz-proxy-logs.conf

# Set proper permissions for OJS files and create log directory
RUN chown -R apache:apache /var/www/html && \
    find /var/www/html -type d -exec chmod 775 {} \; && \
    find /var/www/html -type f -exec chmod 664 {} \; && \
    mkdir -p /var/www/logs && \
    chown -R apache:apache /var/www/logs && \
    chmod -R 775 /var/www/logs

# Start Apache in foreground
CMD ["httpd", "-D", "FOREGROUND"]
