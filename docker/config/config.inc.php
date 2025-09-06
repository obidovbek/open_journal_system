<?php

/**
 * Open Journal Systems Configuration File
 * See config.TEMPLATE.inc.php for detailed configuration options
 */

;;;;;;;;;;;;;;;;;;
; General Settings ;
;;;;;;;;;;;;;;;;;;

[general]

; Database connection settings
driver = mysqli
host = ojs-mysql-service-fstu
username = ojs_fstu_user
password = secure_ojs_fstu_password
name = ojs_fstu_db

; Base URL and path settings
base_url = "https://publications.fstu.uz"
base_path = ""

; Force SSL/HTTPS
force_ssl = On
force_login_ssl = On

; Session settings
session_cookie_name = OJSSID
session_cookie_path = /
session_cookie_domain = publications.fstu.uz
session_cookie_secure = On

; Security settings
allowed_hosts = "publications.fstu.uz"

; File and directory settings
files_dir = /var/www/files
public_files_dir = /var/www/html/public

; Locale settings
locale = en_US
client_charset = utf-8
connection_charset = utf8
database_charset = utf8

; I18n settings
installed = Off
enable_cdn = Off

; Site settings
site_title = "FSTU Publications"
site_logo = ""

; Email settings
default_envelope_sender = ""
allow_envelope_sender = Off

; Cache settings
cache = file

; Debug settings (disable in production)
show_stacktrace = Off
deprecation_warnings = Off

; OAI settings
oai_def_id = "publications.fstu.uz"

; Security settings
api_key_secret = ""
encryption = sha1

; Session settings
session_lifetime = 30
session_regenerate = On

; Upload settings
max_file_uploads = 20
upload_max_filesize = 50M
post_max_size = 50M

; Path info settings
disable_path_info = Off
restful_urls = On

;;;;;;;;;;;;;;;;;;
; File Settings  ;
;;;;;;;;;;;;;;;;;;

[files]

; Complete path to directory to store uploaded files
; This directory should not be web-accessible
files_dir = /var/www/files

; Path to the directory to store public uploaded files
; This directory should be web-accessible and specified by the base_url
public_files_dir = /var/www/html/public

; Permissions to set on created directories and files
umask = 0022

;;;;;;;;;;;;;;;;;;
; Security       ;
;;;;;;;;;;;;;;;;;;

[security]

; Force SSL connections site-wide
force_ssl = On

; Force SSL connections for login
force_login_ssl = On

; Allowed hosts (prevent host header injection)
allowed_hosts = "publications.fstu.uz"

; API key encryption method
encryption = sha1

; Prevent clickjacking
frame_options_deny = On

;;;;;;;;;;;;;;;;;;
; Database       ;
;;;;;;;;;;;;;;;;;;

[database]

driver = mysqli
host = ojs-mysql-service-fstu
username = ojs_fstu_user
password = secure_ojs_fstu_password
name = ojs_fstu_db
charset = utf8
collation = utf8_general_ci

; Use persistent connections
persistent = Off

; Debug SQL queries (disable in production)
debug = Off

;;;;;;;;;;;;;;;;;;
; Cache          ;
;;;;;;;;;;;;;;;;;;

[cache]

; Cache type: none, file, memcache, xcache, apc
cache = file

; Cache directory (for file cache)
cache_dir = cache

; Memcache settings (if using memcache)
memcache_hostname = localhost
memcache_port = 11211

;;;;;;;;;;;;;;;;;;
; Email          ;
;;;;;;;;;;;;;;;;;;

[email]

; Default envelope sender
default_envelope_sender = ""
allow_envelope_sender = Off

; SMTP settings
smtp = Off
smtp_server = localhost
smtp_port = 25
smtp_auth = Off
smtp_username = ""
smtp_password = ""

;;;;;;;;;;;;;;;;;;
; Logging        ;
;;;;;;;;;;;;;;;;;;

[logging]

; Enable logging
enable_logging = On

; Log file location
log_dir = logs

; Log level: ERROR, WARNING, NOTICE, INFO, DEBUG
log_level = ERROR

;;;;;;;;;;;;;;;;;;
; OAI Settings   ;
;;;;;;;;;;;;;;;;;;

[oai]

; OAI-PMH repository identifier
repository_id = "publications.fstu.uz"

; Maximum number of records to return in a single request
max_records = 100

; Number of seconds to cache OAI responses
cache_hours = 24

;;;;;;;;;;;;;;;;;;
; Proxy Settings ;
;;;;;;;;;;;;;;;;;;

[proxy]

; HTTP proxy configuration
http_proxy = ""
proxy_username = ""
proxy_password = ""

; Bypass proxy for local addresses
no_proxy = "localhost,127.0.0.1"

;;;;;;;;;;;;;;;;;;
; Session        ;
;;;;;;;;;;;;;;;;;;

[sessions]

; Session handler: php, database, memcache
handler = php

; Session lifetime in minutes
lifetime = 30

; Regenerate session ID on login
regenerate = On

; Session cookie settings
cookie_name = OJSSID
cookie_path = /
cookie_domain = publications.fstu.uz
cookie_secure = On
cookie_httponly = On 