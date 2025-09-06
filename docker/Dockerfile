FROM pkpofficial/ojs:3_4_0-5

# Set working directory
WORKDIR /var/www/html

# Install additional packages if needed (Alpine Linux uses apk)
RUN apk update && apk add --no-cache \
    curl \
    zip \
    unzip \
    openssl

# Create necessary directories and set permissions
RUN mkdir -p /var/www/logs \
    && mkdir -p /etc/ssl/apache2 \
    && mkdir -p /var/www/html/cache \
    && mkdir -p /var/www/html/public \
    && mkdir -p /var/www/files

# Generate self-signed SSL certificate if it doesn't exist
RUN if [ ! -f /etc/ssl/apache2/server.pem ]; then \
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/apache2/server.key \
        -out /etc/ssl/apache2/server.pem \
        -subj "/C=UZ/ST=Tashkent/L=Tashkent/O=FSTU/CN=publications.fstu.uz"; \
    fi

# Copy custom configuration if needed
COPY config/ /var/www/html/config/

# Set proper ownership and permissions for all directories
# In Alpine Linux, www-data has UID 82, not 33 like in Debian/Ubuntu
RUN chown -R 82:82 /var/www/html \
    && chown -R 82:82 /var/www/files \
    && chown -R 82:82 /var/www/logs \
    && chmod -R 755 /var/www/html \
    && chmod -R 755 /var/www/files \
    && chmod -R 755 /var/www/logs \
    && chmod 644 /var/www/html/config/* \
    && chmod 666 /var/www/html/config.inc.php

# Expose port
EXPOSE 80

# Use the same CMD as the base image (don't override it)
# The base image already has the correct startup command 