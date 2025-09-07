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

# Ensure sane permissions on config directory
RUN find /var/www/html/config -type d -exec chmod 775 {} \; \
    && find /var/www/html/config -type f -exec chmod 664 {} \;

# Ensure cache directories exist and are writable by the web server user
# Alpine base image may not include a www-data user. Create it so chown works.
RUN getent group www-data || addgroup -g 82 -S www-data \
    && getent passwd www-data || adduser -u 82 -S -G www-data www-data

# Now adjust ownership/permissions
RUN mkdir -p /var/www/html/cache/opcache \
    && chown -R 82:82 /var/www/html/cache \
    && chmod -R 775 /var/www/html/cache

# Expose port
EXPOSE 80
#
# Use the same CMD as the base image (don't override it)
# The base image already has the correct startup command 