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

# Create proxy setup PHP file
RUN echo '<?php' > /var/www/html/proxy-setup.php && \
    echo '// Set up proxy detection for OJS' >> /var/www/html/proxy-setup.php && \
    echo 'if (isset($_SERVER["HTTP_X_FORWARDED_PROTO"]) && $_SERVER["HTTP_X_FORWARDED_PROTO"] === "https") {' >> /var/www/html/proxy-setup.php && \
    echo '    $_SERVER["HTTPS"] = "on";' >> /var/www/html/proxy-setup.php && \
    echo '    $_SERVER["SERVER_PORT"] = 443;' >> /var/www/html/proxy-setup.php && \
    echo '}' >> /var/www/html/proxy-setup.php && \
    echo 'if (isset($_SERVER["HTTP_X_FORWARDED_PORT"])) {' >> /var/www/html/proxy-setup.php && \
    echo '    $_SERVER["SERVER_PORT"] = $_SERVER["HTTP_X_FORWARDED_PORT"];' >> /var/www/html/proxy-setup.php && \
    echo '}' >> /var/www/html/proxy-setup.php

# Create PHP configuration for proxy
RUN echo '; Proxy configuration for OJS' > /usr/local/etc/php/conf.d/99-proxy.ini && \
    echo '; Trust proxy headers' >> /usr/local/etc/php/conf.d/99-proxy.ini && \
    echo 'auto_prepend_file = /var/www/html/proxy-setup.php' >> /usr/local/etc/php/conf.d/99-proxy.ini

# Create startup script
RUN echo '#!/bin/sh' > /usr/local/bin/ojs-start.sh && \
    echo '' >> /usr/local/bin/ojs-start.sh && \
    echo '# Set environment variables for HTTPS detection' >> /usr/local/bin/ojs-start.sh && \
    echo 'export HTTPS=on' >> /usr/local/bin/ojs-start.sh && \
    echo 'export HTTP_X_FORWARDED_PROTO=https' >> /usr/local/bin/ojs-start.sh && \
    echo 'export HTTP_X_FORWARDED_PORT=443' >> /usr/local/bin/ojs-start.sh && \
    echo 'export SERVER_PORT=443' >> /usr/local/bin/ojs-start.sh && \
    echo '' >> /usr/local/bin/ojs-start.sh && \
    echo 'echo "Starting OJS with HTTPS proxy support..."' >> /usr/local/bin/ojs-start.sh && \
    echo '' >> /usr/local/bin/ojs-start.sh && \
    echo '# Start the original OJS process' >> /usr/local/bin/ojs-start.sh && \
    echo 'exec /usr/local/bin/apache2-foreground' >> /usr/local/bin/ojs-start.sh

RUN chmod +x /usr/local/bin/ojs-start.sh

# The base image already has proper permissions set up
# Just ensure config files have correct permissions
RUN chmod -R 644 /var/www/html/config/

# Expose port
EXPOSE 80

# Use our custom startup script
CMD ["/usr/local/bin/ojs-start.sh"] 