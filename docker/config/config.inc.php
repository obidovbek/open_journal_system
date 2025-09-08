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

; Base URL - MUST be HTTPS for your domain
base_url = https://publications.fstu.uz

; Force SSL/HTTPS for all requests
force_ssl = On

; Trust proxy headers (important for reverse proxy setups)
; This allows OJS to properly detect HTTPS when behind nginx proxy
trusted_proxies = "192.168.10.0/24,172.16.0.0/12,10.0.0.0/8,127.0.0.1"

; Force login over SSL
force_login_ssl = On

; Session settings
session_lifetime = 30

; Email settings
default_envelope_sender = noreply@fstu.uz
allow_envelope_sender = On

; Captcha settings
captcha = off

; Debugging
show_stacktrace = Off
log_errors = On

; Additional security settings for proxy setup
; Allow OJS to detect the real client IP behind proxy
proxy_x_forwarded_for = On

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

;;;;;;;;;;;;;;;;;;;;;
; Security Settings ;
;;;;;;;;;;;;;;;;;;;;;

[security]
; Force secure cookies when using HTTPS
force_ssl = On
allowed_hosts = "publications.fstu.uz" 