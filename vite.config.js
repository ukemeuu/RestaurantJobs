import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
    build: {
        rollupOptions: {
            input: {
                main: resolve(__dirname, 'index.html'),
                jobs: resolve(__dirname, 'jobs.html'),
                apply: resolve(__dirname, 'apply.html'),
                employerLogin: resolve(__dirname, 'employer-login.html'),
                employerRegister: resolve(__dirname, 'employer-register.html'),
                employerDashboard: resolve(__dirname, 'employer-dashboard.html'),
                // adminDashboard: resolve(__dirname, 'dashboard.html'), // Consolidated
                pricing: resolve(__dirname, 'pricing.html'),
                auth: resolve(__dirname, 'auth.html'),
                settings: resolve(__dirname, 'settings.html'),
                candidateDashboard: resolve(__dirname, 'candidate-dashboard.html'),
                jobDetails: resolve(__dirname, 'job-details.html'),
                // Added missing pages
                blog: resolve(__dirname, 'blog.html'),
                blogInterview: resolve(__dirname, 'blog-restaurant-interview-questions.html'),
                blogSalaries: resolve(__dirname, 'blog-restaurant-salaries-kenya.html'),
                blogChef: resolve(__dirname, 'blog-how-to-become-chef-kenya.html'),
                blogCv: resolve(__dirname, 'blog-restaurant-cv-writing-guide.html'),
                blogChains: resolve(__dirname, 'blog-top-restaurant-chains-hiring-kenya.html'),
                blogTop2026: resolve(__dirname, 'blog-top-restaurants-2026.html'),
                postJob: resolve(__dirname, 'post-job.html'),
                candidateRegister: resolve(__dirname, 'candidate-register.html'),
                candidatePremium: resolve(__dirname, 'candidate-premium.html'),
                premiumCheckout: resolve(__dirname, 'premium-checkout.html'),
                // savedJobs: resolve(__dirname, 'saved-jobs.html'),
                viewApplicants: resolve(__dirname, 'view-applicants.html'),
                jobSuccess: resolve(__dirname, 'job-success.html'),
                subscriptionSuccess: resolve(__dirname, 'subscription-success.html'),
                candidateAssessment: resolve(__dirname, 'candidate-assessment.html'),
                adminAssessmentResults: resolve(__dirname, 'admin-assessment-results.html'),
                adminEmployers: resolve(__dirname, 'admin-employers.html'),

                // Recruiter Pages
                recruiters: resolve(__dirname, 'recruiters.html'),
                recruiterRegister: resolve(__dirname, 'recruiter-register.html'),
                recruiterDashboard: resolve(__dirname, 'recruiter-dashboard.html'),
                adminRecruiters: resolve(__dirname, 'admin-recruiters.html'),
            },
        },
    },
});
