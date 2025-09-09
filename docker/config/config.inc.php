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

force_ssl = On                     ; requires correct X-Forwarded-Proto from proxy
session_cookie_secure = On
trust_x_forwarded_for = On

session_lifetime = 30

default_envelope_sender = "noreply@yourdomain.com"
allow_envelope_sender = On

captcha = off

show_stacktrace = Off
log_errors = On

;;;;;;;;;;;;;;;;;;;;;;
; Database Settings  ;
;;;;;;;;;;;;;;;;;;;;;;

[database]
driver = mysql
host = ojs-mysql
username = ojs_user
password = ojs_password
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
