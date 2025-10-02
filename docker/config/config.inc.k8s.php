; OJS Configuration File - Kubernetes Version with Environment Variable Support

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
salt = "OJSSaltChangeThis"

files_dir = /var/www/files         ; keep outside web root
; public dir is managed by the app; no public_files_dir key is needed

; Base URL - will be overridden by environment variable if set
base_url = "${BASE_URL|https://publications.fstu.uz}"
base_url[index] = "${BASE_URL|https://publications.fstu.uz}"

; Critical HTTPS settings for reverse proxy
force_ssl = On                     ; requires correct X-Forwarded-Proto from proxy
session_cookie_secure = On
trust_x_forwarded_for = On
allowed_hosts = "publications.fstu.uz"

; Additional proxy settings
proxy_x_forwarded_for = On
proxy_x_forwarded_host = On
proxy_x_forwarded_proto = On
proxy_x_forwarded_port = On

; IMPORTANT: Don't force login SSL redirects - let nginx/ingress handle all redirects
; force_login_ssl = Off  ; Commented out to prevent internal redirects

session_lifetime = 30

default_envelope_sender = "${OJS_DEFAULT_ENVELOPE_SENDER|noreply@fstu.uz}"
allow_envelope_sender = On

captcha = off

show_stacktrace = Off
log_errors = On

; Security headers
disable_path_info = Off

;;;;;;;;;;;;;;;;;;;;;;
; Database Settings  ;
;;;;;;;;;;;;;;;;;;;;;;

[database]
driver = mysql
; Read from environment variables for Kubernetes
host = "${OJS_DB_HOST|localhost}"
username = "${OJS_DB_USER|ojs_user}"
password = "${OJS_DB_PASSWORD|changeme}"
name = "${OJS_DB_NAME|ojs_db}"
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
smtp_server = "${OJS_SMTP_SERVER|localhost}"
smtp_port = "${OJS_SMTP_PORT|25}"
; smtp_auth = PLAIN
; smtp_username =
; smtp_password =
; smtp_secure = tls

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
; Additional security for HTTPS
allowed_hosts = "publications.fstu.uz"

