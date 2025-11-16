<?php
/**
 * Email Test Script for Guest Submission Form
 * 
 * This script tests if your server can send emails properly.
 * Access this file via browser to test email functionality.
 * 
 * IMPORTANT: Delete this file after testing for security reasons!
 */

// Configuration - Change these to your test values
$test_email = 'obidov.bekzod94@gmail.com'; // Change to your email
$admin_email = 'stj_admin@fstu.uz'; // Change to admin email

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Test - Guest Submission Form</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2563eb;
            border-bottom: 3px solid #2563eb;
            padding-bottom: 10px;
        }
        .warning {
            background: #fef3c7;
            border-left: 4px solid #f59e0b;
            padding: 15px;
            margin: 20px 0;
        }
        .success {
            background: #d1fae5;
            border-left: 4px solid #059669;
            padding: 15px;
            margin: 20px 0;
        }
        .error {
            background: #fee2e2;
            border-left: 4px solid #dc2626;
            padding: 15px;
            margin: 20px 0;
        }
        .info {
            background: #dbeafe;
            border-left: 4px solid #2563eb;
            padding: 15px;
            margin: 20px 0;
        }
        button {
            background: #2563eb;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            margin: 10px 5px;
        }
        button:hover {
            background: #1d4ed8;
        }
        .test-result {
            margin: 20px 0;
            padding: 15px;
            border-radius: 6px;
        }
        code {
            background: #f3f4f6;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: monospace;
        }
        pre {
            background: #1f2937;
            color: #f3f4f6;
            padding: 15px;
            border-radius: 6px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📧 Email Test Script</h1>
        
        <div class="warning">
            <strong>⚠️ Security Warning:</strong> Delete this file after testing! This script should not be accessible in production.
        </div>

        <?php
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $test_type = $_POST['test_type'] ?? '';
            
            echo '<div class="info"><strong>Testing email functionality...</strong></div>';
            
            if ($test_type === 'simple') {
                // Simple email test
                $subject = 'Test Email - Guest Submission Form';
                $message = 'This is a test email from the guest submission form. If you receive this, your email configuration is working correctly.';
                $headers = "From: Test <noreply@fstu.uz>\r\n";
                $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";
                
                $result = mail($test_email, $subject, $message, $headers);
                
                if ($result) {
                    echo '<div class="success">';
                    echo '<strong>✓ Simple Email Test: SUCCESS</strong><br>';
                    echo 'A test email has been sent to: <code>' . htmlspecialchars($test_email) . '</code><br>';
                    echo 'Check your inbox (and spam folder) for the test email.';
                    echo '</div>';
                } else {
                    echo '<div class="error">';
                    echo '<strong>✗ Simple Email Test: FAILED</strong><br>';
                    echo 'Failed to send test email. Check your server\'s mail configuration.';
                    echo '</div>';
                }
                
            } elseif ($test_type === 'html') {
                // HTML email test
                $subject = 'HTML Test Email - Guest Submission Form';
                $message = '
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                </head>
                <body style="font-family: Arial, sans-serif; padding: 20px;">
                    <div style="background: #2563eb; color: white; padding: 20px; border-radius: 8px;">
                        <h1 style="margin: 0;">HTML Email Test</h1>
                    </div>
                    <div style="padding: 20px; background: #f9fafb; margin-top: 20px; border-radius: 8px;">
                        <p>This is a <strong>test HTML email</strong> from the guest submission form.</p>
                        <p>If you can see this formatted message, HTML emails are working correctly.</p>
                        <ul>
                            <li>✓ HTML formatting</li>
                            <li>✓ Inline styles</li>
                            <li>✓ Special characters: © ® ™</li>
                        </ul>
                    </div>
                </body>
                </html>
                ';
                
                $headers = "From: Test <noreply@fstu.uz>\r\n";
                $headers .= "MIME-Version: 1.0\r\n";
                $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
                
                $result = mail($test_email, $subject, $message, $headers);
                
                if ($result) {
                    echo '<div class="success">';
                    echo '<strong>✓ HTML Email Test: SUCCESS</strong><br>';
                    echo 'An HTML test email has been sent to: <code>' . htmlspecialchars($test_email) . '</code><br>';
                    echo 'Check your inbox for a formatted email.';
                    echo '</div>';
                } else {
                    echo '<div class="error">';
                    echo '<strong>✗ HTML Email Test: FAILED</strong><br>';
                    echo 'Failed to send HTML email.';
                    echo '</div>';
                }
                
            } elseif ($test_type === 'attachment') {
                // Email with attachment test
                $subject = 'Attachment Test Email - Guest Submission Form';
                
                // Create a simple test file content
                $testFileContent = "This is a test document for the guest submission form.\n\nIf you can read this, file attachments are working correctly.";
                $testFileName = "test-document.txt";
                
                $boundary = md5(time());
                
                $headers = "From: Test <noreply@fstu.uz>\r\n";
                $headers .= "MIME-Version: 1.0\r\n";
                $headers .= "Content-Type: multipart/mixed; boundary=\"{$boundary}\"\r\n";
                
                $message = "--{$boundary}\r\n";
                $message .= "Content-Type: text/html; charset=UTF-8\r\n";
                $message .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
                $message .= "<html><body><h2>Attachment Test</h2><p>This email includes a test attachment. If you can download and open it, attachments are working correctly.</p></body></html>\r\n";
                
                $message .= "--{$boundary}\r\n";
                $message .= "Content-Type: text/plain; name=\"{$testFileName}\"\r\n";
                $message .= "Content-Transfer-Encoding: base64\r\n";
                $message .= "Content-Disposition: attachment; filename=\"{$testFileName}\"\r\n\r\n";
                $message .= chunk_split(base64_encode($testFileContent)) . "\r\n";
                $message .= "--{$boundary}--";
                
                $result = mail($test_email, $subject, $message, $headers);
                
                if ($result) {
                    echo '<div class="success">';
                    echo '<strong>✓ Attachment Email Test: SUCCESS</strong><br>';
                    echo 'An email with attachment has been sent to: <code>' . htmlspecialchars($test_email) . '</code><br>';
                    echo 'Check your inbox for an email with a <code>test-document.txt</code> attachment.';
                    echo '</div>';
                } else {
                    echo '<div class="error">';
                    echo '<strong>✗ Attachment Email Test: FAILED</strong><br>';
                    echo 'Failed to send email with attachment.';
                    echo '</div>';
                }
            }
        }
        ?>

        <h2>Select Test Type</h2>
        <p>Choose a test to verify your email configuration:</p>

        <form method="POST">
            <button type="submit" name="test_type" value="simple">
                📨 Test Simple Email
            </button>
            <button type="submit" name="test_type" value="html">
                🎨 Test HTML Email
            </button>
            <button type="submit" name="test_type" value="attachment">
                📎 Test Email with Attachment
            </button>
        </form>

        <div class="info" style="margin-top: 30px;">
            <h3>📋 Configuration Check</h3>
            <p><strong>Test Email:</strong> <code><?php echo htmlspecialchars($test_email); ?></code></p>
            <p><strong>Admin Email:</strong> <code><?php echo htmlspecialchars($admin_email); ?></code></p>
            <p><strong>PHP mail() function:</strong> <?php echo function_exists('mail') ? '✓ Available' : '✗ Not available'; ?></p>
            <p><strong>Sendmail path:</strong> <code><?php echo ini_get('sendmail_path') ?: 'Not configured'; ?></code></p>
        </div>

        <div class="info">
            <h3>🔧 PHP Configuration</h3>
            <pre><?php
echo "upload_max_filesize: " . ini_get('upload_max_filesize') . "\n";
echo "post_max_size: " . ini_get('post_max_size') . "\n";
echo "max_execution_time: " . ini_get('max_execution_time') . "s\n";
echo "memory_limit: " . ini_get('memory_limit') . "\n";
echo "file_uploads: " . (ini_get('file_uploads') ? 'Enabled' : 'Disabled') . "\n";
            ?></pre>
        </div>

        <div class="warning" style="margin-top: 30px;">
            <h3>⚠️ Before Testing</h3>
            <ol>
                <li>Update <code>$test_email</code> in this file to your email address</li>
                <li>Ensure your server has mail functionality configured</li>
                <li>Check that your firewall allows outbound SMTP connections (port 25/587)</li>
                <li>After testing, <strong>DELETE THIS FILE</strong> for security</li>
            </ol>
        </div>

        <div class="info">
            <h3>📚 Troubleshooting</h3>
            <p>If emails are not being sent:</p>
            <ul>
                <li>Check PHP error logs: <code>/var/log/php-errors.log</code></li>
                <li>Check mail logs: <code>/var/log/mail.log</code></li>
                <li>Verify sendmail is installed: <code>which sendmail</code></li>
                <li>Test sendmail directly: <code>echo "Test" | sendmail -v your@email.com</code></li>
                <li>Consider using SMTP instead of sendmail</li>
                <li>Check if your hosting provider blocks mail() function</li>
            </ul>
        </div>
    </div>
</body>
</html>

