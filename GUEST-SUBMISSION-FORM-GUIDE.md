# Guest Submission Form - Implementation Guide

## Overview

This guest submission form allows authors to submit manuscripts to your OJS journal without requiring registration or login. The form implements **Option 1: Email Notification + Manual Admin Entry**, which is the most reliable and straightforward approach.

## Files Created

The following files have been created in the `data/ojs-app/public/` directory:

1. **guest-submission.html** - The main HTML form
2. **guest-submission.css** - Styling for the form
3. **guest-submission.js** - JavaScript for form validation and interactivity
4. **guest-submission-handler.php** - Backend PHP script to process submissions

## Form Features

### 1. Author Information
- **Dynamic Author Addition**: Users can add multiple co-authors using the "+ Add Author" button
- **Required Fields per Author**:
  - Title (dropdown: Dr., Prof., Assoc. Prof., etc.)
  - Name
  - Surname
  - Authorship (First Author, Co-Author, Corresponding Author)
  - Email (with validation)
  - Address
  - Affiliation

### 2. Submission Details
- **Article Type** (dropdown): Original article, Review article, Case study, etc.
- **Manuscript Title**: Text input
- **Abstract**: Textarea with real-time word counter (max 350 words)

### 3. File Upload
- **Drag & Drop Support**: Users can drag files or browse
- **File Constraints**:
  - Allowed formats: .doc, .docx
  - Maximum size: 17 MB
- **File Preview**: Shows selected file name and size
- **Security**: Backend validates both file extension and MIME type

### 4. Keywords
- Input field for 4-6 keywords separated by semicolons (;)
- Example: "machine learning; artificial intelligence; neural networks"

### 5. Validation
- All required fields are validated on the client-side (JavaScript)
- Server-side validation in PHP for security
- Real-time feedback for word count and file upload

## How It Works

### Submission Flow

1. **User Fills Form**: Guest author completes all required fields
2. **Client Validation**: JavaScript validates all inputs before submission
3. **File Upload**: Manuscript file is validated (type, size)
4. **Server Processing**: PHP handler processes the form data
5. **Email Notifications**:
   - **Admin Email**: Sent to `editor-itj@fstu.uz` with:
     - All submission details (title, abstract, keywords)
     - All author information
     - Manuscript file attached
     - Instructions for manual entry
   - **Author Confirmation**: Sent to submitting author confirming receipt
6. **Success Message**: User sees confirmation modal

### Admin Workflow

When an admin receives the submission email, they should:

1. **Log in to OJS**: Access the OJS admin panel at `https://publications.fstu.uz/itj`
2. **Start New Submission**: Go to Submissions → New Submission
3. **Submit on Behalf**: Click "Submit as..." or "Submit on behalf of..."
4. **Enter Details**: Copy and paste from the email:
   - Author information (all co-authors)
   - Manuscript title
   - Abstract
   - Keywords
   - Article type
5. **Upload File**: Upload the manuscript file attached to the email
6. **Complete Submission**: Finish the 5-step OJS submission process
7. **Assign & Process**: The submission will appear in "Unassigned" queue, ready to be assigned to Section Editors or sent for review

## Configuration

### Email Settings

Edit `guest-submission-handler.php` to configure:

```php
define('ADMIN_EMAIL', 'editor-itj@fstu.uz'); // Change to your admin email
define('SITE_NAME', 'International Technology Journal');
define('SITE_URL', 'https://publications.fstu.uz/itj');
```

### File Upload Limits

The form enforces these limits (configurable in `guest-submission-handler.php`):

```php
define('MAX_FILE_SIZE', 17 * 1024 * 1024); // 17 MB
define('ALLOWED_EXTENSIONS', ['doc', 'docx']);
```

### PHP Mail Configuration

The form uses PHP's built-in `mail()` function. For production use, you may need to configure your server's mail settings or use SMTP.

#### Option A: Use System Sendmail (Default)
The form works out of the box if your server has sendmail configured.

#### Option B: Configure SMTP (Recommended for Production)
For better reliability, consider using PHPMailer with SMTP. You would need to:

1. Install PHPMailer (if not already available in OJS)
2. Modify `guest-submission-handler.php` to use SMTP settings from `config.inc.php`

Example SMTP configuration in OJS's `config.inc.php`:

```ini
[email]
default = smtp
smtp = On
smtp_server = mail.fstu.uz
smtp_port = 587
smtp_auth = tls
smtp_username = your-username
smtp_password = your-password
```

## Accessing the Form

### Direct URL Access
The form can be accessed at:
```
https://publications.fstu.uz/itj/public/guest-submission.html
```

### Integration with OJS

To integrate the form into your OJS site:

#### Option 1: Add Menu Link
1. Log in to OJS as admin
2. Go to Settings → Website → Navigation
3. Add a new navigation menu item:
   - **Title**: "Guest Submission"
   - **URL**: `/public/guest-submission.html`

#### Option 2: Create Custom Page
1. Go to Settings → Website → Static Pages (requires Static Pages plugin)
2. Create a new page with a link to the form

#### Option 3: Add to Homepage
Edit your journal's homepage to include a prominent link or button to the guest submission form.

## Security Considerations

### Implemented Security Measures

1. **File Type Validation**:
   - Client-side: JavaScript checks file extension
   - Server-side: PHP validates both extension and MIME type

2. **File Size Limits**:
   - Client-side: JavaScript checks before upload
   - Server-side: PHP enforces 17 MB limit

3. **Input Sanitization**:
   - All user inputs are sanitized using `htmlspecialchars()`
   - Email addresses are validated using `filter_var()`

4. **CSRF Protection**: Consider adding CSRF tokens for production

5. **Rate Limiting**: Consider implementing rate limiting to prevent spam

### Additional Security Recommendations

1. **Add reCAPTCHA**: Prevent bot submissions
   - Add Google reCAPTCHA v3 to the form
   - Validate on server-side

2. **Implement Rate Limiting**: Prevent abuse
   - Limit submissions per IP address
   - Use session-based throttling

3. **File Scanning**: For high-security environments
   - Integrate antivirus scanning for uploaded files
   - Use ClamAV or similar

## Testing Checklist

Before deploying to production, test the following:

- [ ] Form loads correctly
- [ ] All required field validations work
- [ ] "Add Author" button creates new author fields
- [ ] "Remove Author" button works (cannot remove first author)
- [ ] Abstract word counter updates in real-time
- [ ] Abstract validation prevents submission over 350 words
- [ ] Keywords validation requires 4-6 keywords
- [ ] File upload accepts only .doc and .docx files
- [ ] File upload rejects files over 17 MB
- [ ] Drag and drop file upload works
- [ ] File preview shows correct file name and size
- [ ] Remove file button works
- [ ] Form submission sends email to admin
- [ ] Admin email contains all submission details
- [ ] Manuscript file is attached to admin email
- [ ] Confirmation email is sent to author
- [ ] Success modal displays after submission
- [ ] Form resets after successful submission
- [ ] Error modal displays for failed submissions
- [ ] Mobile responsive design works correctly

## Troubleshooting

### Emails Not Sending

**Problem**: Form submits but no emails are received

**Solutions**:
1. Check PHP mail configuration: `php -i | grep sendmail`
2. Check server mail logs: `/var/log/mail.log`
3. Verify SMTP settings in `config.inc.php`
4. Check spam/junk folders
5. Test with a simple PHP mail script:
   ```php
   <?php
   mail('test@example.com', 'Test', 'Test message');
   ?>
   ```

### File Upload Fails

**Problem**: File upload returns an error

**Solutions**:
1. Check PHP upload settings in `php.ini`:
   ```ini
   upload_max_filesize = 20M
   post_max_size = 20M
   max_execution_time = 300
   ```
2. Verify directory permissions for temp uploads
3. Check server disk space
4. Review error logs: `/var/log/apache2/error.log` or `/var/log/nginx/error.log`

### Form Not Loading

**Problem**: Blank page or 404 error

**Solutions**:
1. Verify files are in correct directory: `data/ojs-app/public/`
2. Check file permissions: `chmod 644 guest-submission.*`
3. Verify web server configuration
4. Check browser console for JavaScript errors

### CORS Issues

**Problem**: Form submission blocked by CORS policy

**Solutions**:
1. Ensure form and handler are on same domain
2. If needed, add CORS headers to PHP handler:
   ```php
   header('Access-Control-Allow-Origin: *');
   header('Access-Control-Allow-Methods: POST');
   ```

## Customization

### Styling

Edit `guest-submission.css` to customize:
- Colors (CSS variables in `:root`)
- Fonts
- Layout spacing
- Button styles

### Form Fields

To add or modify form fields:
1. Edit HTML in `guest-submission.html`
2. Update JavaScript validation in `guest-submission.js`
3. Update PHP processing in `guest-submission-handler.php`
4. Update email templates in PHP handler

### Email Templates

Email templates are in `guest-submission-handler.php`:
- `$adminEmailBody` - Email sent to admin/editor
- `$authorEmailBody` - Confirmation email to author

Customize the HTML to match your branding.

## Future Enhancements (Optional)

### Option 2: Full OJS API Integration

For a fully automated solution, you could implement OJS REST API integration:

1. **API Authentication**: Use OJS API key
2. **Create Submission**: POST to `/api/v1/submissions`
3. **Create Authors**: Associate authors with submission
4. **Upload File**: POST manuscript file to submission
5. **Set Metadata**: Add title, abstract, keywords

**Benefits**:
- Fully automated - no manual entry needed
- Submissions appear directly in OJS queue
- Immediate assignment to Section Editors

**Challenges**:
- More complex implementation
- Requires API key management
- Needs thorough testing with OJS version
- May require creating temporary user accounts

### Additional Features

1. **Multi-language Support**: Add i18n for different languages
2. **Progress Saving**: Allow users to save draft and return later
3. **Co-author Notifications**: Send emails to all co-authors
4. **Submission Tracking**: Provide tracking number for authors
5. **File Preview**: Show document preview before submission
6. **Multiple File Upload**: Allow supplementary files

## Support

For issues or questions:
- **OJS Documentation**: https://docs.pkp.sfu.ca/
- **OJS Forum**: https://forum.pkp.sfu.ca/
- **Email**: editor-itj@fstu.uz

## License

This guest submission form is provided as-is for use with Open Journal Systems (OJS). Modify as needed for your journal's requirements.

---

**Last Updated**: November 16, 2025
**OJS Version Compatibility**: 3.x
**PHP Version**: 7.4+

