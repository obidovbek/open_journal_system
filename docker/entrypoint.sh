#!/bin/sh
set -e

# Substitute environment variables in config file
echo "[Entrypoint] Configuring OJS with environment variables..."

# Set defaults if not provided
BASE_URL=${BASE_URL:-http://localhost:8081}
FORCE_SSL=${FORCE_SSL:-Off}
OJS_DB_HOST=${OJS_DB_HOST:-ojs-mysql}
OJS_DB_USER=${OJS_DB_USER:-ojs_user}
OJS_DB_PASSWORD=${OJS_DB_PASSWORD:-ojs_password}
OJS_DB_NAME=${OJS_DB_NAME:-ojs_db}

echo "[Entrypoint] BASE_URL: $BASE_URL"
echo "[Entrypoint] FORCE_SSL: $FORCE_SSL"

# Create config from template
cp /var/www/html/config/config.inc.php.template /var/www/html/config.inc.php

# Substitute variables
sed -i "s|\${BASE_URL}|$BASE_URL|g" /var/www/html/config.inc.php
sed -i "s|\${FORCE_SSL}|$FORCE_SSL|g" /var/www/html/config.inc.php
sed -i "s|\${OJS_DB_HOST}|$OJS_DB_HOST|g" /var/www/html/config.inc.php
sed -i "s|\${OJS_DB_USER}|$OJS_DB_USER|g" /var/www/html/config.inc.php
sed -i "s|\${OJS_DB_PASSWORD}|$OJS_DB_PASSWORD|g" /var/www/html/config.inc.php
sed -i "s|\${OJS_DB_NAME}|$OJS_DB_NAME|g" /var/www/html/config.inc.php

echo "[Entrypoint] Configuration complete!"

# Execute the original entrypoint
exec /usr/local/bin/ojs-start

