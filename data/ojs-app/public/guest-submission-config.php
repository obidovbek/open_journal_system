<?php
/**
 * Guest Submission Form Configuration
 * 
 * Copy this file and customize the settings for your journal.
 * This file should be included in guest-submission-handler.php
 */

return [
    // Email Configuration
    'admin_email' => 'stj_admin@fstu.uz',
    'site_name' => 'International Technology Journal',
    'site_url' => 'https://publications.fstu.uz/itj',
    'noreply_email' => 'noreply@fstu.uz',
    
    // File Upload Settings
    'max_file_size' => 17 * 1024 * 1024, // 17 MB in bytes
    'allowed_extensions' => ['doc', 'docx'],
    'allowed_mime_types' => [
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ],
    
    // Form Validation Settings
    'max_abstract_words' => 350,
    'min_keywords' => 4,
    'max_keywords' => 6,
    'keyword_separator' => ';',
    
    // Article Type Options
    'article_types' => [
        'Original article',
        'Review article',
        'Case study',
        'Short communication',
        'Technical note'
    ],
    
    // Author Title Options
    'author_titles' => [
        'Dr.',
        'Prof.',
        'Assoc. Prof.',
        'Asst. Prof.',
        'Mr.',
        'Ms.',
        'Mrs.'
    ],
    
    // Authorship Options
    'authorship_types' => [
        'First Author',
        'Co-Author',
        'Corresponding Author'
    ],
    
    // Security Settings
    'enable_recaptcha' => false, // Set to true and configure reCAPTCHA keys
    'recaptcha_site_key' => '',
    'recaptcha_secret_key' => '',
    
    // Rate Limiting (optional)
    'enable_rate_limiting' => false,
    'max_submissions_per_ip' => 5,
    'rate_limit_window' => 3600, // 1 hour in seconds
    
    // Email Settings
    'send_admin_notification' => true,
    'send_author_confirmation' => true,
    'cc_emails' => [], // Additional emails to CC on admin notification
    'bcc_emails' => [], // Additional emails to BCC on admin notification
    
    // Debug Settings
    'debug_mode' => false, // Set to true for development
    'log_submissions' => true, // Log submissions to file
    'log_file_path' => __DIR__ . '/../../logs/guest-submissions.log',
    
    // Custom Messages
    'messages' => [
        'success' => 'Submission successful! A confirmation email has been sent to your email address.',
        'error_generic' => 'An error occurred while submitting your manuscript. Please try again.',
        'error_file_size' => 'File size exceeds the maximum limit of 17 MB.',
        'error_file_type' => 'Only .doc and .docx files are allowed.',
        'error_email_failed' => 'Failed to send notification emails. Please contact the administrator.',
    ],
    
    // Admin Email Template Customization
    'admin_email_template' => [
        'subject_prefix' => 'New Guest Submission: ',
        'include_submission_date' => true,
        'include_ip_address' => false, // For tracking purposes
    ],
    
    // Author Email Template Customization
    'author_email_template' => [
        'subject' => 'Submission Confirmation - International Technology Journal',
        'include_next_steps' => true,
        'estimated_review_time' => '2-4 weeks', // Display in confirmation email
    ]
];

