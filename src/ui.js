
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
export function getSavedJobs() {
    const saved = localStorage.getItem('restaurant_saved_jobs');
    return saved ? JSON.parse(saved) : [];
}

export function isJobSaved(id) {
    const saved = getSavedJobs();
    return saved.includes(id);
}

export function toggleSaveJob(id) {
    let saved = getSavedJobs();
    if (saved.includes(id)) {
        saved = saved.filter(jobId => jobId !== id);
        showToast('Job removed from favorites', 'success');
    } else {
        saved.push(id);
        showToast('Job saved to favorites', 'success');
    }
    localStorage.setItem('restaurant_saved_jobs', JSON.stringify(saved));
    return saved.includes(id);
}

// Auth State Management
export async function updateNavAuth() {
    const { data: { session } } = await supabase.auth.getSession();
    const authBtn = document.getElementById('nav-auth-btn');

    // Toggle Sign In / Sign Out button
    if (authBtn) {
        if (session) {
            authBtn.innerText = 'Sign Out';
            authBtn.href = '#'; // Prevent navigation
            authBtn.onclick = async (e) => {
                e.preventDefault();
                await supabase.auth.signOut();
                window.location.href = '/'; // Redirect to home after sign out
            };
        } else {
            authBtn.innerText = 'Sign In';
            authBtn.href = '/auth.html';
            authBtn.onclick = null; // Remove previous handler if any
        }
    }
}

// Auto-initialize if running in browser
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        setupMobileMenu();
        updateNavAuth(); // Check auth on load
    });
}
