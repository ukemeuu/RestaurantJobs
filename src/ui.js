
// UI Utilities for RestaurantJobs
import { supabase } from './supabaseClient.js';

/**
 * Initializes the mobile menu functionality.
 * Expects a button with id 'mobile-menu-btn' and a nav container with id 'nav-links'.
 */
export function setupMobileMenu() {
    const btn = document.getElementById('mobile-menu-btn');
    const nav = document.getElementById('nav-links');

    if (btn && nav) {
        btn.addEventListener('click', () => {
            nav.classList.toggle('active');
            const isExpanded = nav.classList.contains('active');
            btn.setAttribute('aria-expanded', isExpanded);
            btn.innerHTML = isExpanded ? '&times;' : '&#9776;'; // Switch between Hamburger and Close
        });
    }
}

/**
 * Shows a toast notification.
 * @param {string} message - The message to display.
 * @param {string} type - 'success' or 'error' (default: 'success').
 */
export function showToast(message, type = 'success') {
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerText = message;

    container.appendChild(toast);

    // Trigger animation
    requestAnimationFrame(() => {
        toast.classList.add('show');
    });

    // Remove after 3 seconds
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => {
            container.removeChild(toast);
        }, 300); // Wait for fade out transition
    }, 3000);
}

// Saved Jobs Management
export async function getSavedJobs() {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) return [];

    const { data, error } = await supabase
        .from('saved_jobs')
        .select('job_id')
        .eq('user_id', session.user.id);

    if (error || !data) return [];
    return data.map(item => item.job_id);
}

export async function isJobSaved(id) {
    const saved = await getSavedJobs();
    return saved.includes(id);
}

export async function toggleSaveJob(id, btnElement) {
    const { data: { session } } = await supabase.auth.getSession();

    // 1. Check Auth
    if (!session) {
        showToast('Please sign in to save jobs', 'error');
        return false;
    }

    const startIcon = btnElement ? btnElement.innerText : '';

    // 2. Check Role (Candidate only)
    const { data: roleData } = await supabase
        .from('user_roles')
        .select('role')
        .eq('id', session.user.id)
        .single();

    if (roleData?.role !== 'candidate') {
        showToast('Only candidates can save jobs', 'error');
        return false;
    }

    // 3. Toggle in DB
    // First, check if already saved
    const { data: existing } = await supabase
        .from('saved_jobs')
        .select('id')
        .eq('user_id', session.user.id)
        .eq('job_id', id)
        .single();

    let isSaved = false;

    if (existing) {
        // Remove
        const { error } = await supabase
            .from('saved_jobs')
            .delete()
            .eq('id', existing.id);

        if (!error) {
            showToast('Job removed from saved', 'success');
            isSaved = false;
        }
    } else {
        // Add
        const { error } = await supabase
            .from('saved_jobs')
            .insert([{ user_id: session.user.id, job_id: id }]);

        if (!error) {
            showToast('Job saved successfully', 'success');
            isSaved = true;
        }
    }

    return isSaved;
}

// Auth & Navigation State Management
export async function updateNavigation() {
    // 1. Check Session
    const { data: { session } } = await supabase.auth.getSession();
    const user = session?.user;

    // 2. Get Elements
    const authBtn = document.getElementById('nav-auth-btn'); // Link: "Sign In"
    const signOutBtn = document.getElementById('nav-signout-btn'); // Button: "Sign Out"
    const navLinks = document.getElementById('nav-links');

    // 3. Update UI based on User State
    if (!user) {
        // --- GUEST STATE ---
        if (authBtn) {
            authBtn.style.display = 'inline-block';
            authBtn.innerText = 'Sign In';
            authBtn.href = '/auth.html';
        }
        if (signOutBtn) signOutBtn.style.display = 'none';

        // Hide Dashboard links
        toggleLink(navLinks, '/employer-dashboard.html', false);
        toggleLink(navLinks, '/candidate-dashboard.html', false);
        toggleLink(navLinks, '/settings.html', false);

        // Guest: specific formatting
        toggleLink(navLinks, '/employer-register.html', true, 'Submit Job');
        toggleLink(navLinks, '/post-job.html', false);
        return;
    }

    // --- AUTHENTICATED STATE ---

    // Hide "Sign In" link
    if (authBtn) authBtn.style.display = 'none';

    // Hide Guest Submit Job link
    toggleLink(navLinks, '/employer-register.html', false);

    // Remove Top Nav Sign Out (moved to Settings)
    if (signOutBtn) signOutBtn.style.display = 'none';

    // 4. Check Role
    const { data: roleData } = await supabase
        .from('user_roles')
        .select('role')
        .eq('id', user.id)
        .single();

    const role = roleData?.role || 'candidate';

    // 5. Update UI based on Role
    if (role === 'employer' || role === 'admin') {
        toggleLink(navLinks, '/employer-dashboard.html', true, 'Dashboard');
        // toggleLink(navLinks, '/post-job.html', true, 'Post a Job'); // User requested removal
        toggleLink(navLinks, '/settings.html', true, 'Settings');

        toggleLink(navLinks, '/candidate-dashboard.html', false);
        toggleLink(navLinks, '/apply.html', false);
        toggleLink(navLinks, '/jobs.html', false); // Employers/Admins don't need Find Jobs
        toggleLink(navLinks, '/post-job.html', false); // Post a Job removed from nav
    } else {
        // CANDIDATE
        toggleLink(navLinks, '/candidate-dashboard.html', true, 'Dashboard');
        toggleLink(navLinks, '/settings.html', true, 'Settings');
        toggleLink(navLinks, '/employer-dashboard.html', false);
        toggleLink(navLinks, '/post-job.html', false);
        toggleLink(navLinks, '/jobs.html', true, 'Find Jobs');

        // Check if CV already submitted
        const { count } = await supabase
            .from('applications')
            .select('*', { count: 'exact', head: true })
            .eq('candidate_id', user.id);

        if (count && count > 0) {
            // Already has CV -> Show "Apply for Jobs" 
            // Actually, best to just show "Find Jobs" and let the button on job details handle logic
            toggleLink(navLinks, '/apply.html', false);
        } else {
            // No CV -> Show "Submit CV"
            toggleLink(navLinks, '/apply.html', true, 'Submit CV');
        }
    }
}

// Helper to toggle link visibility or add it
function toggleLink(container, href, shouldShow, text) {
    if (!container) return;

    let link = container.querySelector(`a[href="${href}"]`);

    if (shouldShow) {
        if (link) {
            link.style.display = 'inline-block';
            if (text) link.innerText = text;
        } else {
            // Only create specific safe links - never create "Find Jobs" or "Post a Job"
            const allowedCreations = ['Dashboard', 'Saved Jobs', 'Settings', 'Submit CV'];
            if (allowedCreations.includes(text)) {
                link = document.createElement('a');
                link.href = href;
                link.innerText = text;
                if (text === 'Dashboard') link.id = 'nav-dashboard';

                const lastItem = container.lastElementChild;
                container.insertBefore(link, lastItem);
            }
        }
    } else {
        if (link) link.style.display = 'none';
    }
}

// Auto-initialize if running in browser
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        setupMobileMenu();
        updateNavigation(); // Run the new robust function
    });
}

// Social Share Modal
export function openShareModal(title, id) {
    let overlay = document.getElementById('share-modal-overlay');
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'share-modal-overlay';
        overlay.className = 'share-modal-overlay';
        document.body.appendChild(overlay);
    }

    // Construct URLs
    const url = window.location.origin + '/job-details.html?id=' + id;
    const text = `Check out this ${title} job on RestaurantJobs Kenya!`;
    const twitterUrl = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(url)}`;
    const linkedinUrl = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`;

    overlay.innerHTML = `
        <div class="share-modal" onclick="event.stopPropagation()">
            <h3>Share this Job</h3>
            <div class="share-options">
                <a href="${twitterUrl}" target="_blank" class="share-btn share-twitter" title="Share on X">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="white"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
                </a>
                <a href="${linkedinUrl}" target="_blank" class="share-btn share-linkedin" title="Share on LinkedIn">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="white"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg>
                </a>
                <button id="copy-link-btn" class="share-btn share-copy" title="Copy Link">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path></svg>
                </button>
            </div>
            <button id="close-share-btn" style="margin-top: 25px; background: none; border: none; color: #999; cursor: pointer; text-decoration: underline; font-size: 0.9rem;">Close</button>
        </div>
    `;

    // Bind events
    document.getElementById('copy-link-btn').onclick = async () => {
        try {
            await navigator.clipboard.writeText(url);
            showToast('Link copied to clipboard!', 'success');
        } catch (e) {
            prompt('Copy this link:', url);
        }
        closeShareModal();
    };

    const closeFunc = () => {
        overlay.classList.remove('active');
        setTimeout(() => overlay.style.display = 'none', 300);
    };

    document.getElementById('close-share-btn').onclick = closeFunc;
    overlay.onclick = closeFunc;

    // Show
    overlay.style.display = 'flex';
    requestAnimationFrame(() => overlay.classList.add('active'));
}
