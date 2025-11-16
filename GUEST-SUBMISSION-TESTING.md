# Guest Submission Form - Testing Checklist

## Pre-Testing Setup

### Environment Verification
- [ ] PHP version 7.4 or higher installed
- [ ] Web server (Apache/Nginx) configured and running
- [ ] OJS installation accessible
- [ ] All form files present in `data/ojs-app/public/`
- [ ] Email configuration completed
- [ ] SSL/HTTPS enabled

### Configuration Check
- [ ] Admin email address configured in `guest-submission-handler.php`
- [ ] Site name and URL configured
- [ ] File upload limits set correctly (17 MB)
- [ ] PHP upload settings configured (`php.ini`)

---

## Functional Testing

### 1. Form Loading & Display

#### Desktop Testing
- [ ] Form loads without errors
- [ ] All sections display correctly
- [ ] CSS styling applied properly
- [ ] No console errors in browser
- [ ] Form is centered and readable
- [ ] Header displays correctly
- [ ] All labels and placeholders visible

#### Mobile Testing (Responsive Design)
- [ ] Form displays correctly on mobile (< 768px)
- [ ] All fields are accessible
- [ ] Buttons are properly sized for touch
- [ ] No horizontal scrolling required
- [ ] Text is readable without zooming
- [ ] Upload area works on mobile

#### Browser Compatibility
- [ ] Chrome/Edge (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

---

### 2. Author Information Section

#### Single Author
- [ ] All fields display correctly
- [ ] Title dropdown shows all options
- [ ] Name field accepts text input
- [ ] Surname field accepts text input
- [ ] Authorship dropdown shows all options
- [ ] Email field validates format
- [ ] Address field accepts text
- [ ] Affiliation field accepts text
- [ ] Required field validation works

#### Multiple Authors
- [ ] "Add Author" button works
- [ ] New author block appears with animation
- [ ] New author fields are numbered correctly (Author 2, Author 3, etc.)
- [ ] All fields in new author block work
- [ ] "Remove Author" button appears for additional authors
- [ ] "Remove Author" button works correctly
- [ ] Cannot remove first author
- [ ] Author numbers update after removal
- [ ] Can add at least 10 authors without issues
- [ ] Smooth scrolling to new author block

#### Field Validation
- [ ] Empty title shows validation error
- [ ] Empty name shows validation error
- [ ] Empty surname shows validation error
- [ ] Empty authorship shows validation error
- [ ] Invalid email format shows error (e.g., "test@")
- [ ] Valid email format accepted (e.g., "test@example.com")
- [ ] Empty address shows validation error
- [ ] Empty affiliation shows validation error

---

### 3. Submission Details Section

#### Article Type
- [ ] Dropdown displays all article types
- [ ] Can select each article type
- [ ] Required validation works
- [ ] Selected value is preserved

#### Manuscript Title
- [ ] Field accepts text input
- [ ] Placeholder displays correctly
- [ ] Required validation works
- [ ] Long titles accepted (test with 200+ characters)
- [ ] Special characters accepted (test: "Title: A Study on α-β Testing")

#### Abstract
- [ ] Textarea displays correctly
- [ ] Placeholder displays correctly
- [ ] Can enter multi-line text
- [ ] Word counter displays "0 / 350 words" initially
- [ ] Word counter updates in real-time
- [ ] Word count is accurate (test with known word count)
- [ ] Counter turns green when under limit
- [ ] Counter turns red when over limit
- [ ] Cannot submit when over 350 words
- [ ] Line breaks preserved in text
- [ ] Special characters accepted

---

### 4. File Upload Section

#### Drag & Drop
- [ ] Drag & drop area displays correctly
- [ ] Upload icon visible
- [ ] Text "Drag & Drop your files here or" displays
- [ ] "Browse files" button displays
- [ ] Constraints text displays: "Supports doc, docx. Max. 17 MB"
- [ ] Drag over area highlights (border changes)
- [ ] Drag leave removes highlight
- [ ] Drop file shows preview
- [ ] Dropping multiple files only accepts first one

#### Browse Files
- [ ] "Browse files" button opens file dialog
- [ ] File dialog filters to .doc and .docx files
- [ ] Selected file shows preview
- [ ] File name displays correctly
- [ ] File size displays correctly (in KB/MB)
- [ ] File icon displays

#### File Validation - Type
- [ ] .doc file accepted
- [ ] .docx file accepted
- [ ] .pdf file rejected with error message
- [ ] .txt file rejected with error message
- [ ] .jpg file rejected with error message
- [ ] File without extension rejected

#### File Validation - Size
- [ ] File under 17 MB accepted
- [ ] File exactly 17 MB accepted
- [ ] File over 17 MB rejected with error message
- [ ] Very small file (1 KB) accepted
- [ ] Error message displays correct size limit

#### File Preview & Removal
- [ ] File preview displays after selection
- [ ] Upload area content hides when preview shows
- [ ] File name truncates if too long
- [ ] File size formats correctly (Bytes, KB, MB)
- [ ] "Remove file" (X) button displays
- [ ] "Remove file" button works
- [ ] Can select new file after removal
- [ ] File input resets after removal

---

### 5. Keywords Section

#### Input & Validation
- [ ] Keywords field displays correctly
- [ ] Placeholder shows correct format
- [ ] Help text displays below field
- [ ] Can enter keywords separated by semicolons
- [ ] Validation requires 4-6 keywords
- [ ] Less than 4 keywords shows error
- [ ] More than 6 keywords shows error
- [ ] Exactly 4 keywords accepted
- [ ] Exactly 6 keywords accepted
- [ ] Spaces around semicolons handled correctly
- [ ] Empty keywords (e.g., "a;;b") handled correctly

#### Test Cases
- [ ] Valid: "keyword1; keyword2; keyword3; keyword4"
- [ ] Valid: "AI; ML; deep learning; neural networks; NLP; computer vision"
- [ ] Invalid: "keyword1; keyword2; keyword3" (only 3)
- [ ] Invalid: "k1; k2; k3; k4; k5; k6; k7" (7 keywords)

---

### 6. Form Submission

#### Pre-Submission Validation
- [ ] Cannot submit with empty required fields
- [ ] Browser shows validation messages for empty fields
- [ ] Abstract over 350 words prevents submission
- [ ] Keywords outside 4-6 range prevents submission
- [ ] Missing file prevents submission
- [ ] All validations show appropriate error messages

#### Submission Process
- [ ] Submit button displays correctly
- [ ] Submit button is dark colored
- [ ] Click submit starts submission
- [ ] Submit button shows loading state
- [ ] Loading spinner displays
- [ ] Button text changes to "Submitting..."
- [ ] Button is disabled during submission
- [ ] Form cannot be submitted twice

#### Successful Submission
- [ ] Success modal appears
- [ ] Success icon (checkmark) displays
- [ ] Success message displays
- [ ] Confirmation text about email displays
- [ ] "Close" button displays
- [ ] Click "Close" dismisses modal
- [ ] Form resets after successful submission
- [ ] All fields cleared
- [ ] File upload reset
- [ ] Word counter reset to 0
- [ ] Additional author blocks removed

#### Failed Submission
- [ ] Error modal appears on failure
- [ ] Error icon displays
- [ ] Error message displays
- [ ] "Close" button displays
- [ ] Click "Close" dismisses error modal
- [ ] Form data preserved after error
- [ ] Can retry submission after error

---

## Email Testing

### Admin Notification Email

#### Delivery
- [ ] Email received by admin address
- [ ] Email not in spam folder
- [ ] Email arrives within 1 minute
- [ ] From address is correct
- [ ] Reply-to is submitting author's email

#### Content - Header
- [ ] Subject line includes manuscript title
- [ ] Email header displays correctly
- [ ] Site name displays in header
- [ ] HTML formatting applied

#### Content - Submission Details
- [ ] Article type displays correctly
- [ ] Manuscript title displays correctly
- [ ] Keywords display correctly
- [ ] All fields properly formatted

#### Content - Abstract
- [ ] Abstract displays in formatted box
- [ ] Line breaks preserved
- [ ] Special characters display correctly
- [ ] Long abstracts display completely

#### Content - Author Information
- [ ] All authors listed
- [ ] Author numbering correct (Author 1, Author 2, etc.)
- [ ] Each author section has colored border
- [ ] All author fields display:
  - [ ] Title
  - [ ] Full name (Name + Surname)
  - [ ] Authorship type
  - [ ] Email
  - [ ] Address
  - [ ] Affiliation

#### Content - File Attachment
- [ ] Manuscript file attached to email
- [ ] File name correct
- [ ] File size correct
- [ ] Can download attachment
- [ ] Can open attachment in Word/compatible software
- [ ] File content intact (not corrupted)

#### Content - Instructions
- [ ] Action required notice displays
- [ ] Next steps instructions display
- [ ] OJS URL included
- [ ] Step-by-step instructions clear
- [ ] Submission timestamp displays

#### HTML Rendering
- [ ] Email displays correctly in Gmail
- [ ] Email displays correctly in Outlook
- [ ] Email displays correctly in Apple Mail
- [ ] Email displays correctly on mobile
- [ ] All colors and styling applied
- [ ] No broken images or layout issues

### Author Confirmation Email

#### Delivery
- [ ] Email received by submitting author
- [ ] Email not in spam folder
- [ ] Email arrives within 1 minute
- [ ] From address is correct
- [ ] Reply-to is admin email

#### Content
- [ ] Subject line correct
- [ ] Header displays correctly
- [ ] Success icon/checkmark displays
- [ ] Personalized greeting with author name
- [ ] Thank you message displays
- [ ] Submission details box displays:
  - [ ] Manuscript title
  - [ ] Article type
  - [ ] Submission timestamp
- [ ] Next steps information included
- [ ] Contact information displays
- [ ] Site URL included
- [ ] Footer displays correctly

#### HTML Rendering
- [ ] Email displays correctly in various clients
- [ ] Mobile rendering correct
- [ ] All formatting applied

---

## Security Testing

### Input Validation

#### SQL Injection Prevention
- [ ] Test with: `'; DROP TABLE users; --`
- [ ] Test with: `' OR '1'='1`
- [ ] Test with: `<script>alert('XSS')</script>`
- [ ] All inputs properly sanitized
- [ ] No SQL errors displayed

#### XSS Prevention
- [ ] Test script tags in title: `<script>alert(1)</script>`
- [ ] Test script tags in abstract
- [ ] Test script tags in author name
- [ ] Test HTML in keywords
- [ ] All inputs properly escaped in emails
- [ ] No scripts executed

#### File Upload Security
- [ ] Cannot upload .php file renamed to .docx
- [ ] Cannot upload .exe file
- [ ] Cannot upload file with double extension (.docx.php)
- [ ] MIME type validation works
- [ ] File content validation works

### Rate Limiting (if implemented)
- [ ] Multiple submissions from same IP tracked
- [ ] Rate limit enforced after threshold
- [ ] Error message displays when rate limited
- [ ] Rate limit resets after time window

### CSRF Protection (if implemented)
- [ ] CSRF token generated
- [ ] CSRF token validated
- [ ] Invalid token rejected

---

## Performance Testing

### Load Time
- [ ] Form loads in under 2 seconds
- [ ] CSS loads without delay
- [ ] JavaScript loads without delay
- [ ] No render-blocking resources

### File Upload Performance
- [ ] 1 MB file uploads in under 5 seconds
- [ ] 10 MB file uploads in under 30 seconds
- [ ] 17 MB file uploads successfully
- [ ] Progress indication during upload (if implemented)
- [ ] No timeout errors

### Submission Processing
- [ ] Form submission completes in under 10 seconds
- [ ] Email sending doesn't timeout
- [ ] Large abstracts (350 words) process correctly
- [ ] Multiple authors (10+) process correctly

### Concurrent Submissions
- [ ] Multiple users can submit simultaneously
- [ ] No database locks or conflicts
- [ ] All submissions processed correctly

---

## Accessibility Testing

### Keyboard Navigation
- [ ] Can tab through all form fields
- [ ] Tab order is logical
- [ ] Can submit form using Enter key
- [ ] Can activate buttons with Space/Enter
- [ ] Focus indicators visible
- [ ] No keyboard traps

### Screen Reader
- [ ] Form labels read correctly
- [ ] Required fields announced
- [ ] Error messages announced
- [ ] Success/error modals announced
- [ ] File upload status announced

### ARIA Labels
- [ ] All form fields have labels
- [ ] Buttons have descriptive labels
- [ ] Error messages associated with fields
- [ ] Modal dialogs have proper roles

### Color Contrast
- [ ] Text meets WCAG AA standards (4.5:1)
- [ ] Buttons have sufficient contrast
- [ ] Error messages are not color-only
- [ ] Focus indicators visible

---

## Integration Testing

### OJS Integration
- [ ] Form accessible from OJS site
- [ ] Form styling matches OJS theme (or is intentionally different)
- [ ] Navigation to form works
- [ ] Return to OJS site works

### Admin Workflow
- [ ] Admin can log in to OJS
- [ ] Admin can access "New Submission"
- [ ] Admin can use "Submit on behalf of" feature
- [ ] Admin can copy/paste from email
- [ ] Admin can upload attached file
- [ ] Admin can complete 5-step submission
- [ ] Submission appears in OJS queue
- [ ] Submission can be assigned to Section Editor
- [ ] Submission can be sent for review

---

## Edge Cases & Error Handling

### Network Issues
- [ ] Graceful handling of network timeout
- [ ] Error message displayed to user
- [ ] Form data not lost on network error
- [ ] Can retry after network error

### Server Errors
- [ ] 500 error handled gracefully
- [ ] Error message displayed to user
- [ ] No sensitive information in error messages

### Browser Issues
- [ ] JavaScript disabled: form still submits (basic HTML form)
- [ ] Cookies disabled: form still works
- [ ] Old browser: graceful degradation

### Data Edge Cases
- [ ] Very long manuscript title (500+ characters)
- [ ] Abstract with exactly 350 words
- [ ] Keywords with special characters
- [ ] Author name with accented characters (José, François)
- [ ] Email with + symbol (test+1@example.com)
- [ ] Multiple authors with same email address

---

## Post-Deployment Testing

### Production Environment
- [ ] Form accessible at production URL
- [ ] SSL certificate valid
- [ ] No mixed content warnings
- [ ] All resources load from HTTPS

### Monitoring
- [ ] Email delivery monitored
- [ ] Error logging configured
- [ ] Submission logging works (if implemented)
- [ ] Can access logs for troubleshooting

### User Feedback
- [ ] Collect feedback from first submissions
- [ ] Monitor for usability issues
- [ ] Track submission completion rate
- [ ] Monitor for spam submissions

---

## Testing Sign-Off

### Completed By
- **Tester Name:** ___________________________
- **Date:** ___________________________
- **Environment:** ☐ Development ☐ Staging ☐ Production

### Test Results
- **Total Tests:** _____ 
- **Passed:** _____
- **Failed:** _____
- **Blocked:** _____

### Critical Issues Found
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Approval
- [ ] All critical tests passed
- [ ] All blockers resolved
- [ ] Ready for production deployment

**Approved By:** ___________________________
**Date:** ___________________________

---

## Automated Testing (Optional)

For future enhancement, consider implementing:

### Unit Tests (JavaScript)
```javascript
// Example: Test word counter
test('word counter counts correctly', () => {
    const text = 'This is a test abstract with ten words here.';
    expect(countWords(text)).toBe(10);
});
```

### Integration Tests (PHP)
```php
// Example: Test form submission
public function testFormSubmission() {
    $response = $this->post('/guest-submission-handler.php', [
        'manuscript_title' => 'Test Title',
        // ... other fields
    ]);
    
    $this->assertEquals(200, $response->status());
}
```

### End-to-End Tests (Selenium/Cypress)
```javascript
// Example: Test complete submission flow
describe('Guest Submission Form', () => {
    it('submits successfully', () => {
        cy.visit('/public/guest-submission.html');
        cy.get('#author_name_0').type('John');
        // ... fill other fields
        cy.get('#submitBtn').click();
        cy.get('#successModal').should('be.visible');
    });
});
```

---

**Testing Complete!** ✅

Remember to re-test after any code changes or updates to OJS.

