; <?php exit; // DO NOT DELETE ?>
; DO NOT DELETE THE ABOVE LINE!!!
; Doing so will expose this configuration file through your web site!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OJS Configuration File
; This file uses environment variables for flexibility between dev and prod
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;
; General Settings ;
;;;;;;;;;;;;;;;;;;;;

[general]

; Installation status (set to On after successful install)
installed = Off

; The canonical URL to the OJS installation
; Set via BASE_URL environment variable
; Dev: http://localhost:8081
; Prod: https://publications.fstu.uz
base_url = "${BASE_URL}"
base_url[index] = "${BASE_URL}"

; Session configuration
session_cookie_name = OJSSID
session_lifetime = 30
session_samesite = Lax

; Encryption and security
encryption = sha1
salt = "OJSSaltChangeThis"

; Timezone
time_zone = "UTC"

; Date and time formats
date_format_short = "Y-m-d"
date_format_long = "F j, Y"
datetime_format_short = "Y-m-d h:i A"
datetime_format_long = "F j, Y - h:i A"
time_format = "h:i A"

; Trust X-Forwarded-For from reverse proxy (only for production)
trust_x_forwarded_for = On
allowed_hosts = ""

; Proxy settings for HTTPS detection (only used in production behind proxy)
proxy_x_forwarded_for = On
proxy_x_forwarded_host = On
proxy_x_forwarded_proto = On
proxy_x_forwarded_port = On

; Scheduled tasks
scheduled_tasks = Off

; Generate RESTful URLs
restful_urls = Off

; Show upgrade warnings
show_upgrade_warning = On

; Enable minified JavaScript
enable_minified = On

;;;;;;;;;;;;;;;;;;;;;;
; Database Settings  ;
;;;;;;;;;;;;;;;;;;;;;;

[database]
driver = mysql
host = ${OJS_DB_HOST}
username = ${OJS_DB_USER}
password = ${OJS_DB_PASSWORD}
name = ${OJS_DB_NAME}
debug = Off
persistent = Off

;;;;;;;;;;;;;;;;;;;
; Cache Settings  ;
;;;;;;;;;;;;;;;;;;;

[cache]
object_cache = none
memcache_hostname = localhost
memcache_port = 11211
web_cache = Off
web_cache_hours = 1

;;;;;;;;;;;;;;;;;;;;;;;;;
; Localization Settings ;
;;;;;;;;;;;;;;;;;;;;;;;;;

[i18n]
locale = en
connection_charset = utf8

;;;;;;;;;;;;;;;;;
; File Settings ;
;;;;;;;;;;;;;;;;;

[files]
files_dir = /var/www/files
umask = 0022

;;;;;;;;;;;;;;;;;;;;;
; Security Settings ;
;;;;;;;;;;;;;;;;;;;;;

[security]
; Force SSL - controlled by FORCE_SSL environment variable
; Dev: Off, Prod: On
force_ssl = ${FORCE_SSL}
force_login_ssl = Off
session_check_ip = On
encryption = sha1
salt = "OJSSaltChangeThis"
api_key_secret = ""
allowed_html = "a[href|target|title],em,strong,cite,code,ul,ol,li[class],dl,dt,dd,b,i,u,img[src|alt],sup,sub,br,p"
allowed_title_html = "b,i,u,sup,sub"

;;;;;;;;;;;;;;;;;;;
; Email Settings  ;
;;;;;;;;;;;;;;;;;;;

[email]
; Default mailer configuration (required in OJS 3.4+)
default = sendmail
sendmail_path = "/usr/sbin/sendmail -bs"
smtp = Off
smtp_server = localhost
smtp_port = 25

;;;;;;;;;;;;;;;;;;;;
; Logging Settings ;
;;;;;;;;;;;;;;;;;;;;

[debug]
deprecation_warnings = Off
display_errors = Off
debug = Off
show_stacktrace = Off

;;;;;;;;;;;;;;;;;;;
; Captcha Settings;
;;;;;;;;;;;;;;;;;;;

[captcha]
recaptcha = off
captcha_on_register = on
captcha_on_login = on
