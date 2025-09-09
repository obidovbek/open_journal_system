FROM pkpofficial/ojs:3_4_0-5

# Set working directory
WORKDIR /var/www/html

# Install additional packages if needed (Alpine Linux uses apk) fi
RUN apk update && apk add --no-cache \
    curl \
    zip \
    unzip

# Copy custom configuration if needed
COPY config/ /var/www/html/config/

# The base image already has proper permissions set up
# Just ensure config files have correct permissions
RUN chmod -R 644 /var/www/html/config/

# Trust HTTPS from reverse proxies (Traefik/Nginx) so OJS generates https URLs
# and avoids mixed-content errors when TLS is terminated upstream.
RUN printf "\n# Trust reverse proxy HTTPS\nSetEnvIf X-Forwarded-Proto \"https\" HTTPS=on\nSetEnvIf X-Forwarded-Port \"443\" SERVER_PORT=443\n" >> /var/www/html/.htaccess

# Add PHP auto-prepend to enforce HTTPS when forwarded
COPY https_forwarded.php /var/www/html/https_forwarded.php
COPY .user.ini /var/www/html/.user.ini

# Add Apache HTTPS configuration directly to httpd.conf
COPY apache-https.conf /tmp/https-proxy.conf
RUN cat /tmp/https-proxy.conf >> /etc/apache2/httpd.conf && rm /tmp/https-proxy.conf

# Ensure proper permissions for all copied files (use apache user for Alpine)
RUN chown apache:apache /var/www/html/https_forwarded.php /var/www/html/.user.ini
RUN chmod 644 /var/www/html/https_forwarded.php /var/www/html/.user.ini

# Expose port
EXPOSE 80
#
# Use the same CMD as the base image (don't override it)
# The base image already has the correct startup command 