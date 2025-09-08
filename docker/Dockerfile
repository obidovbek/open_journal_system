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

# Set environment variables for HTTPS detection
ENV HTTPS=on
ENV HTTP_X_FORWARDED_PROTO=https
ENV HTTP_X_FORWARDED_PORT=443
ENV SERVER_PORT=443

# The base image already has proper permissions set up
# Just ensure config files have correct permissions
RUN chmod -R 644 /var/www/html/config/

# Expose port
EXPOSE 80

# Use the original CMD from the base image (don't override it)
# The base image knows how to start OJS properly 