; OJS Configuration File

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

base_url = "https://publications.fstu.uz"
base_url[index] = "https://publications.fstu.uz"

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

; IMPORTANT: Don't force login SSL redirects - let nginx handle all redirects
; force_login_ssl = Off  ; Commented out to prevent internal redirects

session_lifetime = 30

default_envelope_sender = "noreply@fstu.uz"
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
host = ojs-mysql
username = ojs_user
password = secure_ojs_password
name = ojs_db
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
smtp_server = localhost
smtp_port = 25
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
