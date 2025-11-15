FROM pkpofficial/ojs:3_4_0-5

# Set working directory
WORKDIR /var/www/html

# Install additional packages and enable Apache modules
RUN apk update && apk add --no-cache \
    curl \
    zip \
    unzip

# Enable necessary Apache modules for HTTPS proxy handling
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule headers_module/LoadModule headers_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule setenvif_module/LoadModule setenvif_module/' /etc/apache2/httpd.conf

# Copy custom configuration template
COPY config/config.inc.php /var/www/html/config/config.inc.php.template

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
# Stop the base image from forcing RESTful URLs on before the installer runs
RUN sed -i '/restful_urls = Off/s/^/#/' /usr/local/bin/ojs-pre-start

# Ensure config directory has correct permissions
RUN chmod -R 755 /var/www/html/config/

# Trust HTTPS from reverse proxies (Traefik/Nginx) so OJS generates https URLs
# and provide the rewrite rules required for RESTful URLs (forced on by
# ojs-pre-start inside the base image).
COPY htaccess /var/www/html/.htaccess

# Add PHP auto-prepend to enforce HTTPS when forwarded
COPY https_forwarded.php /var/www/html/https_forwarded.php
COPY .user.ini /var/www/html/.user.ini

# Add Apache HTTPS configuration directly to httpd.conf
COPY apache-https.conf /tmp/https-proxy.conf
RUN cat /tmp/https-proxy.conf >> /etc/apache2/httpd.conf && rm /tmp/https-proxy.conf

# Ensure proper permissions for all copied files (use apache user for Alpine)
RUN chown apache:apache /var/www/html/https_forwarded.php /var/www/html/.user.ini
RUN chmod 644 /var/www/html/https_forwarded.php /var/www/html/.user.ini

# DO NOT add HTTPS redirect rules here - nginx handles the HTTPS redirect
# The container should only handle HTTPS detection, not redirects

# Expose port
EXPOSE 80

# Use custom entrypoint that substitutes environment variables
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 
