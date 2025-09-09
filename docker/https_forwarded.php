<?php
// Comprehensive HTTPS detection for OJS behind reverse proxy
// This ensures OJS installer and runtime always generate https URLs

// Debug: Log headers for troubleshooting (remove in production)
if (getenv('OJS_DEBUG') === 'true') {
    error_log("HTTPS Detection Debug - Headers: " . json_encode([
        'X-Forwarded-Proto' => $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? 'not set',
        'X-Forwarded-Port' => $_SERVER['HTTP_X_FORWARDED_PORT'] ?? 'not set',
        'X-Forwarded-SSL' => $_SERVER['HTTP_X_FORWARDED_SSL'] ?? 'not set',
        'Host' => $_SERVER['HTTP_HOST'] ?? 'not set',
        'Original HTTPS' => $_SERVER['HTTPS'] ?? 'not set'
    ]));
}

// Check forwarded headers from reverse proxy
$forwardedProto = $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '';
$forwardedPort  = $_SERVER['HTTP_X_FORWARDED_PORT'] ?? '';
$forwardedSSL   = $_SERVER['HTTP_X_FORWARDED_SSL'] ?? '';

// Force HTTPS when any proxy indicator is present
$isHTTPS = (
    strcasecmp($forwardedProto, 'https') === 0 ||
    $forwardedPort === '443' ||
    strcasecmp($forwardedSSL, 'on') === 0 ||
    !empty($_SERVER['HTTP_X_FORWARDED_SSL'])
);

// Additional safety: if we're on publications.fstu.uz, always force HTTPS
$host = $_SERVER['HTTP_HOST'] ?? $_SERVER['SERVER_NAME'] ?? '';
if (strpos($host, 'publications.fstu.uz') !== false) {
    $isHTTPS = true;
}

if ($isHTTPS) {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = '443';
    $_SERVER['REQUEST_SCHEME'] = 'https';
    
    // Also set environment variables that some frameworks check
    putenv('HTTPS=on');
    putenv('SERVER_PORT=443');
    
    // Force the protocol in $_SERVER for URL generation
    if (isset($_SERVER['HTTP_HOST'])) {
        // Ensure no port 80 is appended
        if (strpos($_SERVER['HTTP_HOST'], ':80') !== false) {
            $_SERVER['HTTP_HOST'] = str_replace(':80', '', $_SERVER['HTTP_HOST']);
        }
        // Remove any port 8081 that might leak from container
        if (strpos($_SERVER['HTTP_HOST'], ':8081') !== false) {
            $_SERVER['HTTP_HOST'] = str_replace(':8081', '', $_SERVER['HTTP_HOST']);
        }
    }
    
    // Set additional server variables for proper URL generation
    $_SERVER['SERVER_NAME'] = preg_replace('/:\d+$/', '', $_SERVER['HTTP_HOST'] ?? $_SERVER['SERVER_NAME'] ?? '');
    
    // Ensure REQUEST_URI doesn't contain protocol issues
    if (isset($_SERVER['REQUEST_URI'])) {
        $_SERVER['REQUEST_URI'] = $_SERVER['REQUEST_URI'];
    }
}

// Force Content Security Policy to prefer HTTPS
if (!headers_sent()) {
    header('Content-Security-Policy: upgrade-insecure-requests');
    header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
} 