FROM pkpofficial/ojs:3_4_0-5

# Set working directory
WORKDIR /var/www/html

# Install additional packages if needed (Alpine Linux uses apk)
RUN apk update && apk add --no-cache \
    curl \
    zip \
    unzip

# Copy custom configuration directly (no template processing)
COPY config/config.inc.php /var/www/html/config.inc.php

# Fix Apache DocumentRoot to point to /var/www/html
RUN sed -i 's|DocumentRoot "/var/www/localhost/htdocs"|DocumentRoot "/var/www/html"|g' /etc/apache2/httpd.conf && \
    sed -i 's|<Directory "/var/www/localhost/htdocs">|<Directory "/var/www/html">|g' /etc/apache2/httpd.conf

# Set proper permissions and ensure directories exist
RUN mkdir -p /var/www/files /var/www/html/public /var/www/html/cache && \
    chmod -R 755 /var/www/files /var/www/html/public /var/www/html/cache && \
    chmod 644 /var/www/html/config.inc.php

# Set environment variables for HTTPS
ENV HTTPS=on
ENV SERVER_NAME=publications.fstu.uz

# Expose port
EXPOSE 80

# Use the default OJS entrypoint
# The base image already has the correct startup command 