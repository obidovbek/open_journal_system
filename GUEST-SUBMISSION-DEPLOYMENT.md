# Guest Submission Form - Deployment Guide

## Quick Start (5 Minutes)

### Step 1: Verify Files
Ensure these files are in `data/ojs-app/public/`:
- ✅ `guest-submission.html`
- ✅ `guest-submission.css`
- ✅ `guest-submission.js`
- ✅ `guest-submission-handler.php`
- ✅ `guest-submission-config.php` (optional)
- ⚠️ `test-email.php` (delete after testing)

### Step 2: Configure Email Settings

Edit `guest-submission-handler.php` (lines 18-21):

```php
define('ADMIN_EMAIL', 'editor-itj@fstu.uz'); // ← Change this!
define('SITE_NAME', 'International Technology Journal');
define('SITE_URL', 'https://publications.fstu.uz/itj');
```

### Step 3: Test Email Functionality

1. **Update test email address** in `test-email.php`:
   ```php
   $test_email = 'your-email@example.com'; // ← Change this!
   ```

2. **Access test page** in browser:
   ```
   https://publications.fstu.uz/itj/public/test-email.php
   ```

3. **Run all three tests**:
   - 📨 Test Simple Email
   - 🎨 Test HTML Email
   - 📎 Test Email with Attachment

4. **Check your inbox** (and spam folder)

5. **Delete test file** after successful testing:
   ```bash
   rm data/ojs-app/public/test-email.php
   ```

### Step 4: Test the Form

1. **Access the form**:
   ```
   https://publications.fstu.uz/itj/public/guest-submission.html
   ```

2. **Fill out test submission**:
   - Add your email as author
   - Fill all required fields
   - Upload a test .docx file (under 17 MB)
   - Submit

3. **Verify emails received**:
   - Admin should receive email with attachment
   - Author should receive confirmation email

### Step 5: Integrate with OJS

Choose one integration method:

#### Option A: Add Navigation Menu Link (Recommended)
1. Log in to OJS as admin
2. Go to **Settings → Website → Navigation**
3. Click **Add Item** in Primary Navigation
4. Fill in:
   - **Title**: Guest Submission
   - **URL**: `/public/guest-submission.html`
5. Save and reorder as needed

#### Option B: Add to Homepage
1. Go to **Settings → Website → Appearance**
2. Edit **Homepage Content**
3. Add HTML link:
   ```html
   <a href="/public/guest-submission.html" class="btn btn-primary">
       Submit Your Manuscript (Guest)
   </a>
   ```

#### Option C: Create Static Page
1. Enable **Static Pages Plugin** (if not enabled)
2. Go to **Settings → Website → Plugins → Static Pages**
3. Create new page with redirect or iframe to form

---

## Production Deployment Checklist

### Pre-Deployment

- [ ] All files uploaded to correct directory
- [ ] Email settings configured in PHP handler
- [ ] Email tests passed (simple, HTML, attachment)
- [ ] Test submission completed successfully
- [ ] Admin received test email with attachment
- [ ] Author received confirmation email
- [ ] Test email script deleted (`test-email.php`)

### Security

- [ ] File upload directory has correct permissions (755)
- [ ] PHP error display disabled in production (`display_errors = 0`)
- [ ] Consider adding reCAPTCHA (see below)
- [ ] Consider rate limiting (see below)
- [ ] SSL/HTTPS enabled for entire site
- [ ] Review PHP security settings

### Performance

- [ ] PHP upload limits configured:
  ```ini
  upload_max_filesize = 20M
  post_max_size = 20M
  max_execution_time = 300
  memory_limit = 256M
  ```
- [ ] Web server timeout configured (if using nginx/Apache)
- [ ] Email sending tested under load

### Monitoring

- [ ] Set up email delivery monitoring
- [ ] Configure error logging
- [ ] Set up submission tracking (optional)
- [ ] Monitor spam submissions

---

## Server Configuration

### PHP Requirements

**Minimum Requirements:**
- PHP 7.4 or higher
- `mail()` function enabled OR SMTP configured
- `fileinfo` extension enabled
- `mbstring` extension enabled

**Recommended Settings (php.ini):**
```ini
; File Upload Settings
upload_max_filesize = 20M
post_max_size = 20M
max_file_uploads = 20

; Execution Settings
max_execution_time = 300
max_input_time = 300
memory_limit = 256M

; Error Reporting (Production)
display_errors = Off
log_errors = On
error_log = /var/log/php-errors.log

; Security
allow_url_fopen = Off
allow_url_include = Off
```

### Apache Configuration

If using Apache, ensure `.htaccess` allows PHP execution:

```apache
<Files "guest-submission-handler.php">
    Order allow,deny
    Allow from all
</Files>
```

### Nginx Configuration

If using Nginx, ensure PHP-FPM is configured:

```nginx
location ~ \.php$ {
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

### Email Configuration

#### Option 1: System Sendmail (Default)

Verify sendmail is installed:
```bash
which sendmail
# Should output: /usr/sbin/sendmail
```

Test sendmail:
```bash
echo "Test email" | sendmail -v your@email.com
```

#### Option 2: SMTP (Recommended for Production)

Configure in OJS's `config.inc.php`:

```ini
[email]
default = smtp
smtp = On
smtp_server = smtp.gmail.com
smtp_port = 587
smtp_auth = tls
smtp_username = your-email@gmail.com
smtp_password = your-app-password
```

Then modify `guest-submission-handler.php` to use OJS's email system (requires integration with OJS core).

#### Option 3: External Mail Service

For high reliability, use services like:
- **SendGrid**
- **Mailgun**
- **Amazon SES**
- **Postmark**

---

## Advanced Configuration

### Adding reCAPTCHA v3

**1. Get reCAPTCHA Keys:**
- Visit: https://www.google.com/recaptcha/admin
- Register your site
- Get Site Key and Secret Key

**2. Add to HTML** (in `<head>` of `guest-submission.html`):
```html
<script src="https://www.google.com/recaptcha/api.js?render=YOUR_SITE_KEY"></script>
```

**3. Update Form Submission** (in `guest-submission.js`):
```javascript
grecaptcha.ready(function() {
    grecaptcha.execute('YOUR_SITE_KEY', {action: 'submit'}).then(function(token) {
        formData.append('recaptcha_token', token);
        // Continue with form submission
    });
});
```

**4. Verify in PHP** (in `guest-submission-handler.php`):
```php
$recaptcha_token = $_POST['recaptcha_token'] ?? '';
$recaptcha_secret = 'YOUR_SECRET_KEY';

$verify_url = 'https://www.google.com/recaptcha/api/siteverify';
$verify_data = [
    'secret' => $recaptcha_secret,
    'response' => $recaptcha_token,
    'remoteip' => $_SERVER['REMOTE_ADDR']
];

$verify_response = file_get_contents($verify_url . '?' . http_build_query($verify_data));
$verify_result = json_decode($verify_response);

if (!$verify_result->success || $verify_result->score < 0.5) {
    sendResponse(false, 'reCAPTCHA verification failed');
}
```

### Adding Rate Limiting

**Simple IP-based Rate Limiting:**

Add to `guest-submission-handler.php`:

```php
// Rate limiting configuration
$rate_limit_file = sys_get_temp_dir() . '/submission_rate_limit.json';
$max_submissions = 5; // Max submissions per IP
$time_window = 3600; // 1 hour in seconds

// Load rate limit data
$rate_data = [];
if (file_exists($rate_limit_file)) {
    $rate_data = json_decode(file_get_contents($rate_limit_file), true);
}

// Get client IP
$client_ip = $_SERVER['REMOTE_ADDR'];
$current_time = time();

// Clean old entries
$rate_data = array_filter($rate_data, function($timestamp) use ($current_time, $time_window) {
    return ($current_time - $timestamp) < $time_window;
});

// Check rate limit
if (isset($rate_data[$client_ip])) {
    $submissions = array_filter($rate_data[$client_ip], function($timestamp) use ($current_time, $time_window) {
        return ($current_time - $timestamp) < $time_window;
    });
    
    if (count($submissions) >= $max_submissions) {
        sendResponse(false, 'Rate limit exceeded. Please try again later.');
    }
    
    $rate_data[$client_ip][] = $current_time;
} else {
    $rate_data[$client_ip] = [$current_time];
}

// Save rate limit data
file_put_contents($rate_limit_file, json_encode($rate_data));
```

### Adding Submission Logging

Create log file and add to PHP handler:

```php
// Log submission
$log_entry = [
    'timestamp' => date('Y-m-d H:i:s'),
    'ip' => $_SERVER['REMOTE_ADDR'],
    'title' => $manuscriptTitle,
    'author_email' => $submittingAuthorEmail,
    'status' => 'success'
];

$log_file = __DIR__ . '/../../logs/guest-submissions.log';
file_put_contents($log_file, json_encode($log_entry) . "\n", FILE_APPEND);
```

---

## Troubleshooting

### Common Issues

#### 1. Emails Not Received

**Symptoms:** Form submits successfully but no emails arrive

**Solutions:**
1. Check spam/junk folders
2. Verify email configuration in PHP handler
3. Test with `test-email.php`
4. Check server mail logs:
   ```bash
   tail -f /var/log/mail.log
   ```
5. Verify DNS records (SPF, DKIM, DMARC)
6. Check if hosting provider blocks `mail()` function

#### 2. File Upload Fails

**Symptoms:** Error when uploading files

**Solutions:**
1. Check PHP upload limits in `php.ini`
2. Verify directory permissions:
   ```bash
   chmod 755 data/ojs-app/public
   ```
3. Check disk space:
   ```bash
   df -h
   ```
4. Review error logs:
   ```bash
   tail -f /var/log/php-errors.log
   ```

#### 3. Form Not Loading

**Symptoms:** Blank page or 404 error

**Solutions:**
1. Verify file paths are correct
2. Check file permissions:
   ```bash
   chmod 644 guest-submission.*
   ```
3. Check browser console for JavaScript errors
4. Verify web server configuration

#### 4. CORS Errors

**Symptoms:** Form submission blocked by browser

**Solutions:**
1. Ensure form and handler are on same domain
2. Add CORS headers to PHP handler if needed:
   ```php
   header('Access-Control-Allow-Origin: https://publications.fstu.uz');
   header('Access-Control-Allow-Methods: POST');
   ```

#### 5. Large File Upload Timeout

**Symptoms:** Upload fails for files near 17 MB limit

**Solutions:**
1. Increase PHP execution time:
   ```ini
   max_execution_time = 300
   max_input_time = 300
   ```
2. Increase web server timeout (nginx):
   ```nginx
   client_max_body_size 20M;
   proxy_read_timeout 300s;
   ```

---

## Monitoring & Maintenance

### Email Delivery Monitoring

Set up monitoring for:
- Email delivery success rate
- Bounce rate
- Spam complaints

**Tools:**
- Postfix logs: `/var/log/mail.log`
- Email service dashboards (SendGrid, Mailgun, etc.)

### Submission Monitoring

Track:
- Number of submissions per day
- Failed submissions
- Average submission time

**Implementation:**
Add analytics to `guest-submission-handler.php` or use external tools.

### Regular Maintenance

**Weekly:**
- [ ] Check submission logs
- [ ] Verify email delivery
- [ ] Review spam submissions

**Monthly:**
- [ ] Update dependencies (if any)
- [ ] Review security logs
- [ ] Test form functionality
- [ ] Backup submission logs

**Quarterly:**
- [ ] Review and update email templates
- [ ] Update form fields if needed
- [ ] Security audit

---

## Backup & Recovery

### Files to Backup

```bash
# Backup form files
tar -czf guest-submission-backup-$(date +%Y%m%d).tar.gz \
    data/ojs-app/public/guest-submission.*

# Backup logs (if enabled)
tar -czf submission-logs-backup-$(date +%Y%m%d).tar.gz \
    logs/guest-submissions.log
```

### Recovery Procedure

1. Restore files from backup
2. Verify file permissions
3. Test email functionality
4. Test form submission
5. Verify integration with OJS

---

## Performance Optimization

### Caching

Consider caching static assets:

**Apache (.htaccess):**
```apache
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

**Nginx:**
```nginx
location ~* \.(css|js)$ {
    expires 1M;
    add_header Cache-Control "public, immutable";
}
```

### CDN Integration

For high-traffic sites, consider serving static files via CDN:
- Cloudflare
- AWS CloudFront
- Fastly

---

## Support & Updates

### Getting Help

1. **Documentation**: See `GUEST-SUBMISSION-FORM-GUIDE.md`
2. **OJS Forum**: https://forum.pkp.sfu.ca/
3. **Email Support**: editor-itj@fstu.uz

### Future Updates

Check for updates to:
- OJS core system
- PHP version compatibility
- Security patches
- Feature enhancements

---

## License & Credits

This guest submission form is provided as-is for use with Open Journal Systems (OJS).

**Developed for:** International Technology Journal (publications.fstu.uz/itj)
**Date:** November 16, 2025
**Version:** 1.0.0

---

**Ready to Deploy?** Follow the Quick Start guide above! 🚀

