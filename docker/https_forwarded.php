<?php
// Ensure HTTPS is recognized behind a reverse proxy for OJS installer and runtime
// Only set when forwarded headers indicate TLS at the edge
$forwardedProto = $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '';
$forwardedPort  = $_SERVER['HTTP_X_FORWARDED_PORT'] ?? '';

if (strcasecmp($forwardedProto, 'https') === 0 || $forwardedPort === '443') {
	$_SERVER['HTTPS'] = 'on';
	$_SERVER['SERVER_PORT'] = '443';
	// Some frameworks look at REQUEST_SCHEME as well
	$_SERVER['REQUEST_SCHEME'] = 'https';
} 