/**
 * File Upload Security Module
 * Prevents malicious file uploads by validating file signatures, MIME types, and content
 * Based on security best practices from real-world breach analysis
 */

// File signature database (magic bytes)
const FILE_SIGNATURES = {
    // PDF
    pdf: {
        signatures: [[0x25, 0x50, 0x44, 0x46]], // %PDF
        mimeTypes: ['application/pdf'],
        maxSize: 5 * 1024 * 1024 // 5MB
    },
    // Microsoft Word
    doc: {
        signatures: [[0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1]], // DOC
        mimeTypes: ['application/msword'],
        maxSize: 5 * 1024 * 1024
    },
    docx: {
        signatures: [[0x50, 0x4B, 0x03, 0x04]], // ZIP (DOCX is a ZIP)
        mimeTypes: ['application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
        maxSize: 5 * 1024 * 1024
    },
    // Images
    jpg: {
        signatures: [[0xFF, 0xD8, 0xFF]], // JPEG
        mimeTypes: ['image/jpeg', 'image/jpg'],
        maxSize: 2 * 1024 * 1024 // 2MB
    },
    png: {
        signatures: [[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]], // PNG
        mimeTypes: ['image/png'],
        maxSize: 2 * 1024 * 1024
    },
    webp: {
        signatures: [[0x52, 0x49, 0x46, 0x46]], // RIFF (WebP container)
        mimeTypes: ['image/webp'],
        maxSize: 2 * 1024 * 1024
    }
};

/**
 * Read file header bytes
 */
async function readFileHeader(file, bytesToRead = 8) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (e) => {
            const arr = new Uint8Array(e.target.result);
            resolve(Array.from(arr));
        };
        reader.onerror = reject;
        reader.readAsArrayBuffer(file.slice(0, bytesToRead));
    });
}

/**
 * Check if file signature matches expected type
 */
function matchesSignature(fileBytes, signatures) {
    return signatures.some(signature => {
        return signature.every((byte, index) => fileBytes[index] === byte);
    });
}

/**
 * Validate file type by checking magic bytes
 */
async function validateFileSignature(file, allowedTypes) {
    const fileBytes = await readFileHeader(file, 8);

    for (const type of allowedTypes) {
        const typeConfig = FILE_SIGNATURES[type];
        if (!typeConfig) continue;

        if (matchesSignature(fileBytes, typeConfig.signatures)) {
            return { valid: true, detectedType: type };
        }
    }

    return { valid: false, detectedType: null };
}

/**
 * Validate MIME type
 */
function validateMimeType(file, allowedTypes) {
    const fileMime = file.type.toLowerCase();

    for (const type of allowedTypes) {
        const typeConfig = FILE_SIGNATURES[type];
        if (!typeConfig) continue;

        if (typeConfig.mimeTypes.includes(fileMime)) {
            return true;
        }
    }

    return false;
}

/**
 * Validate file size
 */
function validateFileSize(file, allowedTypes) {
    for (const type of allowedTypes) {
        const typeConfig = FILE_SIGNATURES[type];
        if (!typeConfig) continue;

        if (file.size <= typeConfig.maxSize) {
            return { valid: true, maxSize: typeConfig.maxSize };
        }
    }

    return { valid: false, maxSize: 0 };
}

/**
 * Generate secure random filename
 */
function generateSecureFilename(originalExtension) {
    const timestamp = Date.now();
    const randomStr = Math.random().toString(36).substring(2, 15);
    const randomStr2 = Math.random().toString(36).substring(2, 15);
    return `${timestamp}-${randomStr}${randomStr2}.${originalExtension}`;
}

/**
 * Validate image dimensions (prevents zip bombs and oversized images)
 */
async function validateImageDimensions(file, maxWidth = 4000, maxHeight = 4000) {
    return new Promise((resolve) => {
        const img = new Image();
        const url = URL.createObjectURL(file);

        img.onload = () => {
            URL.revokeObjectURL(url);
            const valid = img.width <= maxWidth && img.height <= maxHeight;
            resolve({
                valid,
                width: img.width,
                height: img.height,
                message: valid ? 'Valid dimensions' : `Image too large: ${img.width}x${img.height}. Max: ${maxWidth}x${maxHeight}`
            });
        };

        img.onerror = () => {
            URL.revokeObjectURL(url);
            resolve({ valid: false, message: 'Invalid image file' });
        };

        img.src = url;
    });
}

/**
 * Re-encode image to strip metadata and potential malicious code
 */
async function sanitizeImage(file) {
    return new Promise((resolve, reject) => {
        const img = new Image();
        const url = URL.createObjectURL(file);

        img.onload = () => {
            // Create canvas
            const canvas = document.createElement('canvas');
            canvas.width = img.width;
            canvas.height = img.height;

            // Draw image
            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0);

            // Convert to blob (re-encoded, strips metadata)
            canvas.toBlob((blob) => {
                URL.revokeObjectURL(url);

                if (blob) {
                    // Create new File object
                    const sanitizedFile = new File([blob], file.name, {
                        type: 'image/jpeg',
                        lastModified: Date.now()
                    });
                    resolve(sanitizedFile);
                } else {
                    reject(new Error('Failed to sanitize image'));
                }
            }, 'image/jpeg', 0.92); // JPEG with 92% quality
        };

        img.onerror = () => {
            URL.revokeObjectURL(url);
            reject(new Error('Failed to load image for sanitization'));
        };

        img.src = url;
    });
}

/**
 * Main validation function for resume files
 */
export async function validateResumeFile(file) {
    const allowedTypes = ['pdf', 'doc', 'docx'];
    const errors = [];

    // 1. Check file exists
    if (!file) {
        return { valid: false, errors: ['No file selected'] };
    }

    // 2. Check file extension
    const extension = file.name.split('.').pop().toLowerCase();
    if (!allowedTypes.includes(extension)) {
        errors.push(`Invalid file type. Allowed: ${allowedTypes.join(', ')}`);
    }

    // 3. Validate MIME type
    if (!validateMimeType(file, allowedTypes)) {
        errors.push('File MIME type does not match extension');
    }

    // 4. Validate file signature (magic bytes)
    const signatureCheck = await validateFileSignature(file, allowedTypes);
    if (!signatureCheck.valid) {
        errors.push('File signature verification failed. This may not be a valid document.');
    }

    // 5. Validate file size
    const sizeCheck = validateFileSize(file, allowedTypes);
    if (!sizeCheck.valid) {
        errors.push(`File too large. Maximum size: ${(sizeCheck.maxSize / 1024 / 1024).toFixed(1)}MB`);
    }

    if (errors.length > 0) {
        return { valid: false, errors };
    }

    return {
        valid: true,
        secureFilename: generateSecureFilename(extension),
        detectedType: signatureCheck.detectedType
    };
}

/**
 * Main validation function for logo/image files
 */
export async function validateImageFile(file) {
    const allowedTypes = ['jpg', 'png', 'webp'];
    const errors = [];

    // 1. Check file exists
    if (!file) {
        return { valid: false, errors: ['No file selected'] };
    }

    // 2. Check file extension
    const extension = file.name.split('.').pop().toLowerCase();
    if (!allowedTypes.includes(extension)) {
        errors.push(`Invalid file type. Allowed: ${allowedTypes.join(', ')}`);
    }

    // 3. Validate MIME type
    if (!validateMimeType(file, allowedTypes)) {
        errors.push('File MIME type does not match extension');
    }

    // 4. Validate file signature (magic bytes)
    const signatureCheck = await validateFileSignature(file, allowedTypes);
    if (!signatureCheck.valid) {
        errors.push('File signature verification failed. This may not be a valid image.');
    }

    // 5. Validate file size
    const sizeCheck = validateFileSize(file, allowedTypes);
    if (!sizeCheck.valid) {
        errors.push(`File too large. Maximum size: ${(sizeCheck.maxSize / 1024 / 1024).toFixed(1)}MB`);
    }

    // 6. Validate image dimensions
    const dimensionsCheck = await validateImageDimensions(file);
    if (!dimensionsCheck.valid) {
        errors.push(dimensionsCheck.message);
    }

    if (errors.length > 0) {
        return { valid: false, errors };
    }

    // 7. Sanitize image (re-encode to strip metadata)
    try {
        const sanitizedFile = await sanitizeImage(file);

        return {
            valid: true,
            secureFilename: generateSecureFilename('jpg'), // Always save as JPG after sanitization
            sanitizedFile, // Use this for upload instead of original
            detectedType: signatureCheck.detectedType
        };
    } catch (error) {
        return { valid: false, errors: ['Failed to process image: ' + error.message] };
    }
}

/**
 * Display validation errors to user
 */
export function displayValidationErrors(errors, containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;

    container.innerHTML = `
        <div style="background: #fff3cd; border: 1px solid #ffc107; padding: 15px; border-radius: 8px; margin: 15px 0;">
            <strong style="color: #856404;">⚠️ File Validation Failed:</strong>
            <ul style="margin: 10px 0 0 20px; color: #856404;">
                ${errors.map(err => `<li>${err}</li>`).join('')}
            </ul>
        </div>
    `;
}
