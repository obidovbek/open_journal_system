<?php

/**
 * OJS Configuration File
 * 
 * This file contains configuration settings for Open Journal Systems
 */

;;;;;;;;;;;;;;;;;
; General Setup ;
;;;;;;;;;;;;;;;;;

[general]

; Database connection settings
; Database driver (mysql or postgres)
driver = mysql
host = ojs-mysql
username = ojs_user
password = ojs_password
name = ojs_db

; Locale settings
locale = en_US
client_charset = utf-8
connection_charset = utf8
database_charset = utf8

; Security settings
encryption = sha1
salt = "OJSSaltChangeThis"

; File settings
files_dir = /var/www/files
public_files_dir = /var/www/html/public

; Base URL - will be overridden by environment variable
base_url = https://publications.fstu.uz
base_url[index] = https://publications.fstu.uz

; Enforce HTTPS site-wide so assets/forms use https
force_ssl = On

; Session settings
session_lifetime = 30

; Email settings
default_envelope_sender = noreply@yourdomain.com
allow_envelope_sender = On

; Captcha settings
captcha = off

; Debugging
show_stacktrace = Off
log_errors = On

;;;;;;;;;;;;;;;;;;;;;;
; Database Settings  ;
;;;;;;;;;;;;;;;;;;;;;;

[database]
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

;;;;;;;;;;;;;;;;;;;;
; Logging Settings ;
;;;;;;;;;;;;;;;;;;;;

[debug]
deprecation_warnings = Off
display_errors = Off 