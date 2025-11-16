<?php
/**
 * Guest Submission Form Handler
 * Processes guest manuscript submissions and sends email notifications
 * to the admin/editor for manual entry into OJS
 */

// Set error reporting for debugging (disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 0);

// Set JSON response header
header('Content-Type: application/json');

// Configuration
define('MAX_FILE_SIZE', 17 * 1024 * 1024); // 17 MB
define('ALLOWED_EXTENSIONS', ['doc', 'docx']);
define('ADMIN_EMAIL', 'stj_admin@fstu.uz'); // Change this to your admin email
define('SITE_NAME', 'International Technology Journal');
define('SITE_URL', 'https://publications.fstu.uz/itj');

// Response function
function sendResponse($success, $message, $data = []) {
    echo json_encode(array_merge([
        'success' => $success,
        'message' => $message
    ], $data));
    exit;
}

// Validate request method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, 'Invalid request method');
}

try {
    // Validate and sanitize input data
    $authors = isset($_POST['authors']) ? $_POST['authors'] : [];
    $articleType = isset($_POST['article_type']) ? trim($_POST['article_type']) : '';
    $manuscriptTitle = isset($_POST['manuscript_title']) ? trim($_POST['manuscript_title']) : '';
    $abstract = isset($_POST['abstract']) ? trim($_POST['abstract']) : '';
    $keywords = isset($_POST['keywords']) ? trim($_POST['keywords']) : '';

    // Validation
    $errors = [];

    // Validate authors
    if (empty($authors) || !is_array($authors)) {
        $errors[] = 'At least one author is required';
    } else {
        foreach ($authors as $index => $author) {
            if (empty($author['title']) || empty($author['name']) || empty($author['surname']) || 
                empty($author['authorship']) || empty($author['email']) || 
                empty($author['address']) || empty($author['affiliation'])) {
                $errors[] = "All fields are required for author " . ($index + 1);
            }
            
            // Validate email format
            if (!empty($author['email']) && !filter_var($author['email'], FILTER_VALIDATE_EMAIL)) {
                $errors[] = "Invalid email format for author " . ($index + 1);
            }
        }
    }

    // Validate submission details
    if (empty($articleType)) {
        $errors[] = 'Article type is required';
    }
    if (empty($manuscriptTitle)) {
        $errors[] = 'Manuscript title is required';
    }
    if (empty($abstract)) {
        $errors[] = 'Abstract is required';
    } else {
        // Validate word count
        $wordCount = str_word_count($abstract);
        if ($wordCount > 350) {
            $errors[] = 'Abstract exceeds 350 words';
        }
    }

    // Validate keywords
    if (empty($keywords)) {
        $errors[] = 'Keywords are required';
    } else {
        $keywordArray = array_filter(array_map('trim', explode(';', $keywords)));
        if (count($keywordArray) < 4 || count($keywordArray) > 6) {
            $errors[] = 'Please provide 4-6 keywords';
        }
    }

    // Validate file upload
    if (!isset($_FILES['manuscript_file']) || $_FILES['manuscript_file']['error'] === UPLOAD_ERR_NO_FILE) {
        $errors[] = 'Manuscript file is required';
    } elseif ($_FILES['manuscript_file']['error'] !== UPLOAD_ERR_OK) {
        $errors[] = 'File upload error occurred';
    } else {
        $file = $_FILES['manuscript_file'];
        $fileName = $file['name'];
        $fileSize = $file['size'];
        $fileTmpName = $file['tmp_name'];
        
        // Validate file extension
        $fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
        if (!in_array($fileExtension, ALLOWED_EXTENSIONS)) {
            $errors[] = 'Only .doc and .docx files are allowed';
        }
        
        // Validate file size
        if ($fileSize > MAX_FILE_SIZE) {
            $errors[] = 'File size exceeds 17 MB limit';
        }
        
        // Additional security check - verify MIME type
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $fileTmpName);
        finfo_close($finfo);
        
        $allowedMimeTypes = [
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        ];
        
        if (!in_array($mimeType, $allowedMimeTypes)) {
            $errors[] = 'Invalid file type';
        }
    }

    // Return errors if any
    if (!empty($errors)) {
        sendResponse(false, implode('; ', $errors));
    }

    // Prepare email content
    $submittingAuthor = $authors[0];
    $submittingAuthorEmail = $submittingAuthor['email'];
    
    // Build author list HTML
    $authorListHtml = '';
    foreach ($authors as $index => $author) {
        $authorNum = $index + 1;
        $authorListHtml .= "
        <div style='background: #f9fafb; padding: 15px; margin-bottom: 15px; border-radius: 5px; border-left: 4px solid #2563eb;'>
            <h4 style='margin: 0 0 10px 0; color: #1f2937;'>Author {$authorNum}</h4>
            <p style='margin: 5px 0;'><strong>Title:</strong> " . htmlspecialchars($author['title']) . "</p>
            <p style='margin: 5px 0;'><strong>Name:</strong> " . htmlspecialchars($author['name']) . " " . htmlspecialchars($author['surname']) . "</p>
            <p style='margin: 5px 0;'><strong>Authorship:</strong> " . htmlspecialchars($author['authorship']) . "</p>
            <p style='margin: 5px 0;'><strong>Email:</strong> " . htmlspecialchars($author['email']) . "</p>
            <p style='margin: 5px 0;'><strong>Address:</strong> " . htmlspecialchars($author['address']) . "</p>
            <p style='margin: 5px 0;'><strong>Affiliation:</strong> " . htmlspecialchars($author['affiliation']) . "</p>
        </div>";
    }

    // Admin email content
    $adminEmailSubject = "New Guest Submission: " . $manuscriptTitle;
    $adminEmailBody = "
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset='UTF-8'>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 800px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
            .content { background: white; padding: 30px; border: 1px solid #e5e7eb; border-radius: 0 0 8px 8px; }
            .section { margin-bottom: 25px; }
            .section-title { font-size: 18px; font-weight: bold; color: #2563eb; margin-bottom: 10px; border-bottom: 2px solid #2563eb; padding-bottom: 5px; }
            .info-row { margin: 8px 0; }
            .label { font-weight: bold; color: #1f2937; }
            .abstract-box { background: #f9fafb; padding: 15px; border-radius: 5px; border: 1px solid #e5e7eb; }
            .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb; color: #6b7280; font-size: 14px; }
        </style>
    </head>
    <body>
        <div class='container'>
            <div class='header'>
                <h1 style='margin: 0;'>New Guest Submission</h1>
                <p style='margin: 10px 0 0 0;'>" . SITE_NAME . "</p>
            </div>
            <div class='content'>
                <p style='background: #fef3c7; padding: 15px; border-radius: 5px; border-left: 4px solid #f59e0b;'>
                    <strong>Action Required:</strong> A new manuscript has been submitted via the guest submission form. 
                    Please log in to OJS and manually enter this submission using the \"Submit on behalf of\" feature.
                </p>
                
                <div class='section'>
                    <div class='section-title'>Submission Details</div>
                    <div class='info-row'><span class='label'>Article Type:</span> " . htmlspecialchars($articleType) . "</div>
                    <div class='info-row'><span class='label'>Manuscript Title:</span> " . htmlspecialchars($manuscriptTitle) . "</div>
                    <div class='info-row'><span class='label'>Keywords:</span> " . htmlspecialchars($keywords) . "</div>
                </div>
                
                <div class='section'>
                    <div class='section-title'>Abstract</div>
                    <div class='abstract-box'>" . nl2br(htmlspecialchars($abstract)) . "</div>
                </div>
                
                <div class='section'>
                    <div class='section-title'>Author Information</div>
                    {$authorListHtml}
                </div>
                
                <div class='section'>
                    <div class='section-title'>Manuscript File</div>
                    <p>The manuscript file is attached to this email: <strong>" . htmlspecialchars($fileName) . "</strong></p>
                </div>
                
                <div class='footer'>
                    <p><strong>Next Steps:</strong></p>
                    <ol>
                        <li>Log in to your OJS admin account at " . SITE_URL . "</li>
                        <li>Go to Submissions → New Submission</li>
                        <li>Use the \"Submit on behalf of\" feature</li>
                        <li>Copy and paste the author information, title, abstract, and keywords from this email</li>
                        <li>Upload the attached manuscript file</li>
                        <li>Complete the 5-step submission process</li>
                        <li>Assign to a Section Editor or begin the review process</li>
                    </ol>
                    <p style='margin-top: 15px;'>Submission received: " . date('F j, Y, g:i a') . "</p>
                </div>
            </div>
        </div>
    </body>
    </html>
    ";

    // Author confirmation email
    $authorEmailSubject = "Submission Confirmation - " . SITE_NAME;
    $authorEmailBody = "
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset='UTF-8'>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
            .content { background: white; padding: 30px; border: 1px solid #e5e7eb; border-radius: 0 0 8px 8px; }
            .success-icon { text-align: center; font-size: 48px; color: #059669; margin-bottom: 20px; }
            .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb; color: #6b7280; font-size: 14px; text-align: center; }
        </style>
    </head>
    <body>
        <div class='container'>
            <div class='header'>
                <h1 style='margin: 0;'>Thank You for Your Submission</h1>
            </div>
            <div class='content'>
                <div class='success-icon'>✓</div>
                <p>Dear " . htmlspecialchars($submittingAuthor['title'] . ' ' . $submittingAuthor['name'] . ' ' . $submittingAuthor['surname']) . ",</p>
                
                <p>Thank you for submitting your manuscript to " . SITE_NAME . ". We have successfully received your submission:</p>
                
                <div style='background: #f9fafb; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #2563eb;'>
                    <p style='margin: 5px 0;'><strong>Title:</strong> " . htmlspecialchars($manuscriptTitle) . "</p>
                    <p style='margin: 5px 0;'><strong>Article Type:</strong> " . htmlspecialchars($articleType) . "</p>
                    <p style='margin: 5px 0;'><strong>Submitted:</strong> " . date('F j, Y, g:i a') . "</p>
                </div>
                
                <p>Your manuscript will be reviewed by our editorial team. You will receive further communication regarding the status of your submission.</p>
                
                <p>If you have any questions, please contact us at <a href='mailto:" . ADMIN_EMAIL . "'>" . ADMIN_EMAIL . "</a>.</p>
                
                <div class='footer'>
                    <p>" . SITE_NAME . "<br>
                    <a href='" . SITE_URL . "'>" . SITE_URL . "</a></p>
                </div>
            </div>
        </div>
    </body>
    </html>
    ";

    // Send emails using PHP mail function
    // Note: For production, consider using PHPMailer or SMTP for better reliability
    
    // Prepare headers for admin email with attachment
    $boundary = md5(time());
    
    $adminHeaders = "From: " . SITE_NAME . " <noreply@fstu.uz>\r\n";
    $adminHeaders .= "Reply-To: " . $submittingAuthorEmail . "\r\n";
    $adminHeaders .= "MIME-Version: 1.0\r\n";
    $adminHeaders .= "Content-Type: multipart/mixed; boundary=\"{$boundary}\"\r\n";
    
    // Read file content
    $fileContent = file_get_contents($fileTmpName);
    $fileContent = chunk_split(base64_encode($fileContent));
    
    // Build multipart email
    $adminEmailMessage = "--{$boundary}\r\n";
    $adminEmailMessage .= "Content-Type: text/html; charset=UTF-8\r\n";
    $adminEmailMessage .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
    $adminEmailMessage .= $adminEmailBody . "\r\n";
    
    $adminEmailMessage .= "--{$boundary}\r\n";
    $adminEmailMessage .= "Content-Type: application/octet-stream; name=\"{$fileName}\"\r\n";
    $adminEmailMessage .= "Content-Transfer-Encoding: base64\r\n";
    $adminEmailMessage .= "Content-Disposition: attachment; filename=\"{$fileName}\"\r\n\r\n";
    $adminEmailMessage .= $fileContent . "\r\n";
    $adminEmailMessage .= "--{$boundary}--";
    
    // Send admin email
    $adminEmailSent = mail(ADMIN_EMAIL, $adminEmailSubject, $adminEmailMessage, $adminHeaders);
    
    // Prepare headers for author confirmation email
    $authorHeaders = "From: " . SITE_NAME . " <noreply@fstu.uz>\r\n";
    $authorHeaders .= "Reply-To: " . ADMIN_EMAIL . "\r\n";
    $authorHeaders .= "MIME-Version: 1.0\r\n";
    $authorHeaders .= "Content-Type: text/html; charset=UTF-8\r\n";
    
    // Send author confirmation email
    $authorEmailSent = mail($submittingAuthorEmail, $authorEmailSubject, $authorEmailBody, $authorHeaders);
    
    // Check if emails were sent successfully
    if ($adminEmailSent && $authorEmailSent) {
        sendResponse(true, 'Submission successful! A confirmation email has been sent to your email address.');
    } elseif ($adminEmailSent) {
        sendResponse(true, 'Submission successful! However, we could not send a confirmation email to your address.');
    } else {
        // Log the error for debugging
        error_log('Failed to send submission emails for: ' . $manuscriptTitle);
        sendResponse(false, 'Failed to send submission emails. Please try again or contact the administrator.');
    }

} catch (Exception $e) {
    // Log the error
    error_log('Guest submission error: ' . $e->getMessage());
    sendResponse(false, 'An unexpected error occurred. Please try again later.');
}
?>

