FROM pkpofficial/ojs:3_4_0-5

# Set working directory
WORKDIR /var/www/html

# Install additional packages if needed (Alpine Linux uses apk)
RUN apk update && apk add --no-cache \
    curl \
    zip \
    unzip \
    openssl

# Create necessary directories
RUN mkdir -p /var/www/logs \
    && mkdir -p /etc/ssl/apache2 \
    && mkdir -p /var/www/html/cache \
    && mkdir -p /var/www/html/public \
    && mkdir -p /var/www/files

# Generate self-signed SSL certificate with proper permissions
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/apache2/server.key \
    -out /etc/ssl/apache2/server.pem \
    -subj "/C=UZ/ST=Tashkent/L=Tashkent/O=FSTU/CN=publications.fstu.uz" \
    && chmod 644 /etc/ssl/apache2/server.pem \
    && chmod 644 /etc/ssl/apache2/server.key \
    && chown -R root:root /etc/ssl/apache2

# Copy custom configuration
COPY config/ /var/www/html/config/

# Set proper ownership and permissions for directories that will be mounted
# Use numeric IDs to avoid issues with user name resolution
RUN chown -R 82:82 /var/www/html/config \
    && chmod -R 644 /var/www/html/config/* \
    && chmod 666 /var/www/html/config.inc.php 2>/dev/null || echo "config.inc.php will be created at runtime"

# Expose port
EXPOSE 80

# Use the base image's default startup command 