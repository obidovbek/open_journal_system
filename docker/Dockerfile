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

# Create a simple startup script that sets environment variables
RUN echo '#!/bin/sh' > /usr/local/bin/ojs-start.sh && \
    echo '' >> /usr/local/bin/ojs-start.sh && \
    echo '# Set environment variables for HTTPS detection' >> /usr/local/bin/ojs-start.sh && \
    echo 'export HTTPS=on' >> /usr/local/bin/ojs-start.sh && \
    echo 'export HTTP_X_FORWARDED_PROTO=https' >> /usr/local/bin/ojs-start.sh && \
    echo 'export HTTP_X_FORWARDED_PORT=443' >> /usr/local/bin/ojs-start.sh && \
    echo 'export SERVER_PORT=443' >> /usr/local/bin/ojs-start.sh && \
    echo '' >> /usr/local/bin/ojs-start.sh && \
    echo 'echo "Starting OJS with HTTPS proxy support..."' >> /usr/local/bin/ojs-start.sh && \
    echo 'echo "Environment: HTTPS=$HTTPS, SERVER_PORT=$SERVER_PORT"' >> /usr/local/bin/ojs-start.sh && \
    echo '' >> /usr/local/bin/ojs-start.sh && \
    echo '# Modify PHP environment to detect HTTPS' >> /usr/local/bin/ojs-start.sh && \
    echo 'if [ "$HTTP_X_FORWARDED_PROTO" = "https" ]; then' >> /usr/local/bin/ojs-start.sh && \
    echo '    export HTTPS=on' >> /usr/local/bin/ojs-start.sh && \
    echo '    export SERVER_PORT=443' >> /usr/local/bin/ojs-start.sh && \
    echo 'fi' >> /usr/local/bin/ojs-start.sh && \
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