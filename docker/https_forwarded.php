<?php
// Comprehensive HTTPS detection for OJS behind reverse proxy
// This ensures OJS installer and runtime always generate https URLs

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

if ($isHTTPS) {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = '443';
    $_SERVER['REQUEST_SCHEME'] = 'https';
    
    // Also set environment variables that some frameworks check
    putenv('HTTPS=on');
    putenv('SERVER_PORT=443');
    
    // Force the protocol in $_SERVER for URL generation
    if (isset($_SERVER['HTTP_HOST'])) {
        $_SERVER['HTTP_HOST'] = $_SERVER['HTTP_HOST'];
        // Ensure no port 80 is appended
        if (strpos($_SERVER['HTTP_HOST'], ':80') !== false) {
            $_SERVER['HTTP_HOST'] = str_replace(':80', '', $_SERVER['HTTP_HOST']);
        }
    }
}

// Additional safety: if we're on publications.fstu.uz, always force HTTPS
$host = $_SERVER['HTTP_HOST'] ?? $_SERVER['SERVER_NAME'] ?? '';
if (strpos($host, 'publications.fstu.uz') !== false) {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = '443';
    $_SERVER['REQUEST_SCHEME'] = 'https';
    putenv('HTTPS=on');
    putenv('SERVER_PORT=443');
} 