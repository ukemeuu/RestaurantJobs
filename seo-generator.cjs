const fs = require('fs');
const path = require('path');

// Configuration: Target Keywords (High Volume + High Intent)
const targets = [
    { role: 'Chef', location: 'Nairobi', filename: 'chef-jobs-nairobi.html' },
    { role: 'Waiter', location: 'Nairobi', filename: 'waiter-jobs-nairobi.html' },
    { role: 'Waiter', location: 'Mombasa', filename: 'waiter-jobs-mombasa.html' },
    { role: 'Barista', location: 'Kisumu', filename: 'barista-jobs-kisumu.html' },
    { role: 'Manager', location: 'Nairobi', filename: 'manager-jobs-nairobi.html' },
    { role: 'Bartender', location: 'Mombasa', filename: 'bartender-jobs-mombasa.html' },
    { role: 'Housekeeping', location: 'Nairobi', filename: 'housekeeping-jobs-nairobi.html' },
    { role: 'Cook', location: 'Nakuru', filename: 'cook-jobs-nakuru.html' },
    { role: 'Pastry Chef', location: 'Nairobi', filename: 'pastry-chef-jobs-nairobi.html' },
    { role: 'Receptionist', location: 'Mombasa', filename: 'receptionist-jobs-mombasa.html' },
    { role: 'Sous Chef', location: 'Nairobi', filename: 'sous-chef-jobs-nairobi.html' }
];

const templatePath = path.join(__dirname, 'jobs.html');
const template = fs.readFileSync(templatePath, 'utf-8');

targets.forEach(t => {
    let content = template;

    // 1. Update Title Tag
    // From: <title>Open Positions | RestaurantJobs Kenya</title>
    // To: <title>Chef Jobs in Nairobi | Apply Now | RestaurantJobs Kenya</title>
    const newTitle = `${t.role} Jobs in ${t.location} | Apply Now | RestaurantJobs Kenya`;
    content = content.replace(/<title>.*<\/title>/, `<title>${newTitle}</title>`);

    // 2. Update Meta Description
    const metaDesc = `<meta name="description" content="Browse the latest ${t.role} jobs in ${t.location}. Apply for top restaurant and hotel positions in ${t.location} today on RestaurantJobs Kenya." />`;
    if (content.includes('<meta name="description"')) {
        content = content.replace(/<meta name="description" content=".*">/, metaDesc);
    } else {
        content = content.replace('</head>', `    ${metaDesc}\n</head>`);
    }

    // 3. Update H1
    content = content.replace('Hospitality Jobs in Kenya', `${t.role} Jobs in ${t.location}`);

    // 4. Update Intro Text
    content = content.replace(
        "Discover opportunities at Nairobi's top restaurants and Kenyan resorts.",
        `Find the best ${t.role} vacancies in ${t.location}. Apply to top restaurants and hotels.`
    );

    // 5. Pre-fill Search Inputs
    // Search Text Input
    content = content.replace(
        '<input type="text" id="search-text" placeholder="Chef, Waiter, Manager..."',
        `<input type="text" id="search-text" value="${t.role}" placeholder="Chef, Waiter, Manager..."`
    );

    // Location Select
    const locationRegex = new RegExp(`<option value="${t.location}">`, 'g');
    content = content.replace(locationRegex, `<option value="${t.location}" selected>`);

    // 6. Inject Canonical Tag
    const canonical = `<link rel="canonical" href="https://restaurantjobs.co.ke/${t.filename}" />`;
    content = content.replace('</head>', `    ${canonical}\n</head>`);

    // Write file
    fs.writeFileSync(path.join(__dirname, t.filename), content);
    console.log(`Generated: ${t.filename}`);
});

console.log('SEO Landing Pages generation complete.');
