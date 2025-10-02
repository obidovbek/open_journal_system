#!/bin/sh
set -e

echo "===== OJS Kubernetes Startup ====="
echo "Generating config.inc.php from environment variables..."

# Default values
: ${OJS_DB_HOST:=localhost}
: ${OJS_DB_USER:=ojs_user}
: ${OJS_DB_PASSWORD:=changeme}
: ${OJS_DB_NAME:=ojs_db}
: ${BASE_URL:=https://publications.fstu.uz}
: ${OJS_DEFAULT_ENVELOPE_SENDER:=noreply@fstu.uz}
: ${OJS_SMTP_SERVER:=localhost}
: ${OJS_SMTP_PORT:=25}
: ${OJS_SALT:=OJSSaltChangeThis}

# Debug output (comment out in production)
echo "Database Host: $OJS_DB_HOST"
echo "Database Name: $OJS_DB_NAME"
echo "Database User: $OJS_DB_USER"
echo "Base URL: $BASE_URL"

# Generate config.inc.php from template
cat > /var/www/html/config.inc.php << EOF
; OJS Configuration File - Generated for Kubernetes

;;;;;;;;;;;;;;;;;
; General Setup ;
;;;;;;;;;;;;;;;;;

[general]
installed = Off                    ; set On after successful install
locale = en_US
client_charset = utf-8
connection_charset = utf8
database_charset = utf8

encryption = sha1
salt = "$OJS_SALT"

files_dir = /var/www/files         ; keep outside web root

base_url = "$BASE_URL"
base_url[index] = "$BASE_URL"

; Critical HTTPS settings for reverse proxy
force_ssl = On
session_cookie_secure = On
trust_x_forwarded_for = On
allowed_hosts = "publications.fstu.uz"

; Additional proxy settings
proxy_x_forwarded_for = On
proxy_x_forwarded_host = On
proxy_x_forwarded_proto = On
proxy_x_forwarded_port = On

session_lifetime = 30

default_envelope_sender = "$OJS_DEFAULT_ENVELOPE_SENDER"
allow_envelope_sender = On

captcha = off

show_stacktrace = Off
log_errors = On

disable_path_info = Off

;;;;;;;;;;;;;;;;;;;;;;
; Database Settings  ;
;;;;;;;;;;;;;;;;;;;;;;

[database]
driver = mysql
host = $OJS_DB_HOST
username = $OJS_DB_USER
password = $OJS_DB_PASSWORD
name = $OJS_DB_NAME
debug = Off
persistent = Off

;;;;;;;;;;;;;;;;;;;
; Cache Settings  ;
;;;;;;;;;;;;;;;;;;;

[cache]
cache = file
memcache_hostname = localhost
memcache_port = 11211

;;;;;;;;;;;;;;;;;;;
; Email Settings  ;
;;;;;;;;;;;;;;;;;;;

[email]
smtp = Off
smtp_server = $OJS_SMTP_SERVER
smtp_port = $OJS_SMTP_PORT

;;;;;;;;;;;;;;;;;;;;
; Logging Settings ;
;;;;;;;;;;;;;;;;;;;;

[debug]
deprecation_warnings = Off
display_errors = Off

;;;;;;;;;;;;;;;;;;;;
; Security Settings ;
;;;;;;;;;;;;;;;;;;;;

[security]
allowed_hosts = "publications.fstu.uz"
EOF

# Set proper permissions
chmod 644 /var/www/html/config.inc.php
chown apache:apache /var/www/html/config.inc.php

echo "Config file generated successfully!"
echo ""
echo "===== Waiting for database to be ready ====="

# Wait for MySQL to be ready
until nc -z -v -w30 $OJS_DB_HOST 3306
do
  echo "Waiting for database connection at $OJS_DB_HOST:3306..."
  sleep 5
done

echo "Database is ready!"
echo ""
echo "===== Starting Apache ====="

# Execute the original entrypoint/command
exec httpd -D FOREGROUND

