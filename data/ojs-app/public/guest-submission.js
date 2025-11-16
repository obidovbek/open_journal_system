// Guest Submission Form JavaScript
(function() {
    'use strict';

    let authorCount = 1;
    const MAX_FILE_SIZE = 17 * 1024 * 1024; // 17 MB in bytes
    const ALLOWED_EXTENSIONS = ['doc', 'docx'];
    const MAX_WORDS = 350;

    // DOM Elements
    const form = document.getElementById('guestSubmissionForm');
    const authorsContainer = document.getElementById('authorsContainer');
    const addAuthorBtn = document.getElementById('addAuthorBtn');
    const uploadArea = document.getElementById('uploadArea');
    const fileInput = document.getElementById('manuscript_file');
    const browseBtn = document.getElementById('browseBtn');
    const filePreview = document.getElementById('filePreview');
    const removeFileBtn = document.getElementById('removeFileBtn');
    const abstractTextarea = document.getElementById('abstract');
    const wordCountSpan = document.getElementById('wordCount');
    const submitBtn = document.getElementById('submitBtn');
    const successModal = document.getElementById('successModal');
    const errorModal = document.getElementById('errorModal');
    const closeModalBtn = document.getElementById('closeModalBtn');
    const closeErrorModalBtn = document.getElementById('closeErrorModalBtn');

    // Initialize
    init();

    function init() {
        setupEventListeners();
    }

    function setupEventListeners() {
        // Add Author Button
        addAuthorBtn.addEventListener('click', addAuthorBlock);

        // File Upload
        browseBtn.addEventListener('click', () => fileInput.click());
        fileInput.addEventListener('change', handleFileSelect);
        removeFileBtn.addEventListener('click', removeFile);

        // Drag and Drop
        uploadArea.addEventListener('dragover', handleDragOver);
        uploadArea.addEventListener('dragleave', handleDragLeave);
        uploadArea.addEventListener('drop', handleDrop);

        // Abstract Word Counter
        abstractTextarea.addEventListener('input', updateWordCount);

        // Form Submission
        form.addEventListener('submit', handleSubmit);

        // Modal Close
        closeModalBtn.addEventListener('click', closeSuccessModal);
        closeErrorModalBtn.addEventListener('click', closeErrorModal);
    }

    // Add Author Block
    function addAuthorBlock() {
        const authorBlock = document.createElement('div');
        authorBlock.className = 'author-block';
        authorBlock.setAttribute('data-author-index', authorCount);

        authorBlock.innerHTML = `
            <div class="author-header">
                <h3>Author ${authorCount + 1}</h3>
                <button type="button" class="btn-remove-author" onclick="removeAuthorBlock(${authorCount})">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Remove
                </button>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="author_title_${authorCount}">Title <span class="required">*</span></label>
                    <select id="author_title_${authorCount}" name="authors[${authorCount}][title]" required>
                        <option value="">Your title</option>
                        <option value="Dr.">Dr.</option>
                        <option value="Prof.">Prof.</option>
                        <option value="Assoc. Prof.">Assoc. Prof.</option>
                        <option value="Asst. Prof.">Asst. Prof.</option>
                        <option value="Mr.">Mr.</option>
                        <option value="Ms.">Ms.</option>
                        <option value="Mrs.">Mrs.</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="author_name_${authorCount}">Name <span class="required">*</span></label>
                    <input type="text" id="author_name_${authorCount}" name="authors[${authorCount}][name]" placeholder="First name" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="author_surname_${authorCount}">Surname <span class="required">*</span></label>
                    <input type="text" id="author_surname_${authorCount}" name="authors[${authorCount}][surname]" placeholder="Last name" required>
                </div>
                <div class="form-group">
                    <label for="author_authorship_${authorCount}">Authorship <span class="required">*</span></label>
                    <select id="author_authorship_${authorCount}" name="authors[${authorCount}][authorship]" required>
                        <option value="">Authorship</option>
                        <option value="First Author">First Author</option>
                        <option value="Co-Author">Co-Author</option>
                        <option value="Corresponding Author">Corresponding Author</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="author_email_${authorCount}">Email <span class="required">*</span></label>
                    <input type="email" id="author_email_${authorCount}" name="authors[${authorCount}][email]" placeholder="email@example.com" required>
                </div>
                <div class="form-group">
                    <label for="author_address_${authorCount}">Address <span class="required">*</span></label>
                    <input type="text" id="author_address_${authorCount}" name="authors[${authorCount}][address]" placeholder="Full address" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group full-width">
                    <label for="author_affiliation_${authorCount}">Affiliation <span class="required">*</span></label>
                    <input type="text" id="author_affiliation_${authorCount}" name="authors[${authorCount}][affiliation]" placeholder="University/Institution name" required>
                </div>
            </div>
        `;

        authorsContainer.appendChild(authorBlock);
        authorCount++;

        // Smooth scroll to new author block
        setTimeout(() => {
            authorBlock.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }, 100);
    }

    // Remove Author Block (Global function for inline onclick)
    window.removeAuthorBlock = function(index) {
        const authorBlock = document.querySelector(`[data-author-index="${index}"]`);
        if (authorBlock && authorCount > 1) {
            authorBlock.remove();
            authorCount--;
            updateAuthorNumbers();
        }
    };

    function updateAuthorNumbers() {
        const authorBlocks = document.querySelectorAll('.author-block');
        authorBlocks.forEach((block, index) => {
            const header = block.querySelector('.author-header h3');
            if (header && index > 0) {
                header.textContent = `Author ${index + 1}`;
            }
        });
    }

    // File Upload Handlers
    function handleDragOver(e) {
        e.preventDefault();
        e.stopPropagation();
        uploadArea.classList.add('drag-over');
    }

    function handleDragLeave(e) {
        e.preventDefault();
        e.stopPropagation();
        uploadArea.classList.remove('drag-over');
    }

    function handleDrop(e) {
        e.preventDefault();
        e.stopPropagation();
        uploadArea.classList.remove('drag-over');

        const files = e.dataTransfer.files;
        if (files.length > 0) {
            handleFile(files[0]);
        }
    }

    function handleFileSelect(e) {
        const files = e.target.files;
        if (files.length > 0) {
            handleFile(files[0]);
        }
    }

    function handleFile(file) {
        // Validate file extension
        const fileName = file.name;
        const fileExtension = fileName.split('.').pop().toLowerCase();
        
        if (!ALLOWED_EXTENSIONS.includes(fileExtension)) {
            showError('Invalid file type. Please upload a .doc or .docx file.');
            fileInput.value = '';
            return;
        }

        // Validate file size
        if (file.size > MAX_FILE_SIZE) {
            showError('File size exceeds 17 MB. Please upload a smaller file.');
            fileInput.value = '';
            return;
        }

        // Display file preview
        displayFilePreview(file);
    }

    function displayFilePreview(file) {
        const fileName = file.name;
        const fileSize = formatFileSize(file.size);

        document.getElementById('fileName').textContent = fileName;
        document.getElementById('fileSize').textContent = fileSize;

        uploadArea.querySelector('.upload-content').style.display = 'none';
        filePreview.style.display = 'block';
    }

    function removeFile() {
        fileInput.value = '';
        uploadArea.querySelector('.upload-content').style.display = 'flex';
        filePreview.style.display = 'none';
    }

    function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
    }

    // Word Counter
    function updateWordCount() {
        const text = abstractTextarea.value.trim();
        const words = text ? text.split(/\s+/).filter(word => word.length > 0).length : 0;
        wordCountSpan.textContent = words;

        if (words > MAX_WORDS) {
            wordCountSpan.style.color = '#dc2626';
        } else {
            wordCountSpan.style.color = '#059669';
        }
    }

    // Form Submission
    async function handleSubmit(e) {
        e.preventDefault();

        // Validate abstract word count
        const text = abstractTextarea.value.trim();
        const words = text ? text.split(/\s+/).filter(word => word.length > 0).length : 0;
        if (words > MAX_WORDS) {
            showError(`Abstract exceeds ${MAX_WORDS} words. Please shorten it to ${MAX_WORDS} words or less.`);
            abstractTextarea.focus();
            return;
        }

        // Validate keywords
        const keywords = document.getElementById('keywords').value.trim();
        const keywordArray = keywords.split(';').map(k => k.trim()).filter(k => k.length > 0);
        if (keywordArray.length < 4 || keywordArray.length > 6) {
            showError('Please provide 4-6 keywords separated by semicolons (;).');
            document.getElementById('keywords').focus();
            return;
        }

        // Validate file upload
        if (!fileInput.files || fileInput.files.length === 0) {
            showError('Please upload a manuscript file.');
            return;
        }

        // Show loading state
        setLoadingState(true);

        // Prepare form data
        const formData = new FormData(form);

        try {
            const response = await fetch('guest-submission-handler.php', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                showSuccessModal();
                form.reset();
                removeFile();
                wordCountSpan.textContent = '0';
                
                // Remove additional author blocks
                const authorBlocks = document.querySelectorAll('.author-block');
                authorBlocks.forEach((block, index) => {
                    if (index > 0) {
                        block.remove();
                    }
                });
                authorCount = 1;
            } else {
                showError(result.message || 'An error occurred while submitting your manuscript.');
            }
        } catch (error) {
            console.error('Submission error:', error);
            showError('Network error. Please check your connection and try again.');
        } finally {
            setLoadingState(false);
        }
    }

    function setLoadingState(loading) {
        const btnText = submitBtn.querySelector('.btn-text');
        const btnLoader = submitBtn.querySelector('.btn-loader');

        if (loading) {
            btnText.style.display = 'none';
            btnLoader.style.display = 'flex';
            submitBtn.disabled = true;
        } else {
            btnText.style.display = 'inline';
            btnLoader.style.display = 'none';
            submitBtn.disabled = false;
        }
    }

    // Modal Functions
    function showSuccessModal() {
        successModal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeSuccessModal() {
        successModal.style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    function showError(message) {
        document.getElementById('errorMessage').textContent = message;
        errorModal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function closeErrorModal() {
        errorModal.style.display = 'none';
        document.body.style.overflow = 'auto';
    }

})();

