// Follow this setup guide to integrate the Deno runtime into your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This function will be called by Supabase Database Webhooks

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

const handler = async (request: Request): Promise<Response> => {
    if (request.method !== "POST") {
        return new Response("Method Not Allowed", { status: 405 });
    }

    try {
        const payload = await request.json();
        const { type, record } = payload; // 'type' sent from webhook args, 'record' is the row data

        // Default: Send to Admin (You)
        const ADMIN_EMAIL = "ukememudofia@gmail.com";

        let subject = "";
        let html = "";
        let to = ADMIN_EMAIL; // Default recipient

        // 1. New Application Received
        if (type === "INSERT" && payload.table === "applications") {
            subject = `New Application: ${record.name}`;
            html = `
        <h1>New Job Application</h1>
        <p><strong>Candidate:</strong> ${record.name}</p>
        <p><strong>Position:</strong> ${record.position}</p>
        <p><strong>Email:</strong> ${record.email}</p>
        <p><a href="https://restaurantjobs.pages.dev/dashboard.html">View in Dashboard</a></p>
      `;
        }
        // 2. New Job Posted (Review)
        else if (type === "INSERT" && payload.table === "jobs") {
            subject = `New Job Posted: ${record.title}`;
            html = `
        <h1>New Job Pending Review</h1>
        <p><strong>Title:</strong> ${record.title}</p>
        <p><strong>Location:</strong> ${record.location}</p>
        <p><strong>Type:</strong> ${record.type}</p>
      `;
        }
        // 3. Hiring Request
        else if (type === "INSERT" && payload.table === "hiring_requests") {
            subject = `New Agency Request: ${record.title}`;
            html = `
        <h1>New Hiring Request</h1>
        <p><strong>Org:</strong> ${record.org_name || 'N/A'}</p>
        <p><strong>Title:</strong> ${record.title}</p>
      `;
        }
        else {
            return new Response("No email trigger for this event", { status: 200 });
        }

        if (!RESEND_API_KEY) {
            console.error("No RESEND_API_KEY set");
            return new Response("Server Configuration Error", { status: 500 });
        }

        const res = await fetch("https://api.resend.com/emails", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${RESEND_API_KEY}`,
            },
            body: JSON.stringify({
                from: "RestaurantJobs <onboarding@resend.dev>", // Or your custom domain
                to: [to],
                subject: subject,
                html: html,
            }),
        });

        const data = await res.json();
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { "Content-Type": "application/json" },
        });

    } catch (err) {
        console.error(err);
        return new Response(JSON.stringify({ error: err.message }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
        });
    }
};

serve(handler);
