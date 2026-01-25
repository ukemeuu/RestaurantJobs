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
                adminDashboard: resolve(__dirname, 'dashboard.html'),
                pricing: resolve(__dirname, 'pricing.html'),
                auth: resolve(__dirname, 'auth.html'),
                settings: resolve(__dirname, 'settings.html'),
                candidateDashboard: resolve(__dirname, 'candidate-dashboard.html'),
                jobDetails: resolve(__dirname, 'job-details.html'),
            },
        },
    },
});
