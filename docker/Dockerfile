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

# Create a startup script to handle proxy configuration
RUN cat > /usr/local/bin/ojs-start.sh << 'EOF'
#!/bin/sh

# Set environment variables for HTTPS detection
export HTTPS=on
export HTTP_X_FORWARDED_PROTO=https
export HTTP_X_FORWARDED_PORT=443
export SERVER_PORT=443

# Update PHP configuration for proxy handling
echo "Setting up PHP for proxy..."
cat >> /usr/local/etc/php/conf.d/99-proxy.ini << 'PHPEOF'
; Proxy configuration for OJS
; Trust proxy headers
auto_prepend_file = /var/www/html/proxy-setup.php
PHPEOF

# Create proxy setup file
cat > /var/www/html/proxy-setup.php << 'PHPSETUP'
<?php
// Set up proxy detection for OJS
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = 443;
}
if (isset($_SERVER['HTTP_X_FORWARDED_PORT'])) {
    $_SERVER['SERVER_PORT'] = $_SERVER['HTTP_X_FORWARDED_PORT'];
}
PHPSETUP

# Start the original OJS process
exec /usr/local/bin/apache2-foreground
EOF

RUN chmod +x /usr/local/bin/ojs-start.sh

# The base image already has proper permissions set up
# Just ensure config files have correct permissions
RUN chmod -R 644 /var/www/html/config/

# Expose port
EXPOSE 80

# Use our custom startup script
CMD ["/usr/local/bin/ojs-start.sh"] 