/**
 * AI Generator Service
 * Simulates AI generation using smart templates for hospitality roles.
 * Can be replaced by real LLM call in future.
 */

const roleTemplates = {
    'chef': {
        responsibilities: [
            "Plan and direct food preparation and culinary activities.",
            "Modify menus or create new ones that meet quality standards.",
            "Estimate food requirements and food/labor costs.",
            "Supervise kitchen staff's activities.",
            "Arrange for equipment purchases and repairs."
        ],
        requirements: [
            "Proven working experience as a Head Chef.",
            "Excellent record of kitchen management.",
            "Ability to spot and resolve problems efficiently.",
            "Capable of delegating multiple tasks.",
            "Communication and leadership skills."
        ]
    },
    'cook': {
        responsibilities: [
            "Set up workstations with all needed ingredients and cooking equipment.",
            "Prepare ingredients to use during cooking (chopping and peeling vegetables, cutting meat etc.).",
            "Cook food in various utensils or grillers.",
            "Ensure great presentation by dressing dishes before they are served.",
            "Keep a sanitized and orderly environment in the kitchen."
        ],
        requirements: [
            "Proven experience as cook.",
            "Experience in using cutting tools, cookware and bakeware.",
            "Knowledge of various cooking procedures and methods (grilling, baking, boiling etc.).",
            "Ability to follow all sanitation procedures.",
            "Ability to work in a team."
        ]
    },
    'waiter': {
        responsibilities: [
            "Greet and escort customers to their tables.",
            "Present menu and provide detailed information when asked (e.g. about portions, ingredients or potential food allergies).",
            "Prepare tables by setting up linens, silverware and glasses.",
            "Inform customers about the day's specials.",
            "Offer menu recommendations upon request."
        ],
        requirements: [
            "Proven work experience as a Waiter or Waitress.",
            "Basic math skills.",
            "Attentiveness and patience for customers.",
            "Excellent presentation skills.",
            "Strong organizational and multitasking skills, with the ability to perform well in a fast-paced environment."
        ]
    },
    'server': { // Alias for waiter
        alias: 'waiter'
    },
    'bartender': {
        responsibilities: [
            "Prepare alcohol or non-alcohol beverages for bar and restaurant patrons.",
            "Interact with customers, take orders and serve snacks and drinks.",
            "Assess customers' needs and preferences and make recommendations.",
            "Mix ingredients to prepare cocktails.",
            "Check customers' identification and confirm it meets legal drinking age."
        ],
        requirements: [
            "Resume and proven working experience as a Bartender.",
            "Excellent knowledge of in mixing, garnishing and serving drinks.",
            "Computer literacy.",
            "Knowledge of a second language is a plus.",
            "Positive attitude and excellent communication skills."
        ]
    },
    'manager': {
        responsibilities: [
            "Coordinate daily Front of the House and Back of the House restaurant operations.",
            "Deliver superior service and maximize customer satisfaction.",
            "Respond efficiently and accurately to customer complaints.",
            "Regularly review product quality and research new vendors.",
            "Organize and supervise shifts."
        ],
        requirements: [
            "Proven work experience as a Restaurant Manager, Restaurant General Manager or similar role.",
            "Proven customer service experience as a manager.",
            "Extensive food and beverage (F&B) knowledge, with ability to remember and recall ingredients and dishes to inform customers and wait staff.",
            "Familiarity with restaurant management software.",
            "Strong leadership, motivational and people skills."
        ]
    }
};

const genericTemplate = {
    responsibilities: [
        "Perform daily tasks to ensure smooth operation of the business.",
        "Collaborate with team members to achieve goals.",
        "Maintain a clean and safe working environment.",
        "Follow all company policies and procedures.",
        "Provide excellent customer service."
    ],
    requirements: [
        "Previous experience in a similar role is a plus.",
        "Strong communication and interpersonal skills.",
        "Reliable and punctual.",
        "Ability to work in a fast-paced environment.",
        "Willingness to learn and grow."
    ]
};

export async function generateJobDescription(jobTitle, location, type) {
    // Artificial delay to simulate AI thinking
    await new Promise(resolve => setTimeout(resolve, 1500));

    const titleLower = jobTitle.toLowerCase();

    // Find best matching template
    let templateKey = Object.keys(roleTemplates).find(key => titleLower.includes(key));
    let template = templateKey ? roleTemplates[templateKey] : genericTemplate;

    // Handle alias
    if (template.alias) {
        template = roleTemplates[template.alias];
    }

    // Build the HTML
    const responsibilitiesList = template.responsibilities.map(item => `<li>${item}</li>`).join('');
    const requirementsList = template.requirements.map(item => `<li>${item}</li>`).join('');

    return `
        <p>We are looking for a skilled <strong>${jobTitle}</strong> to join our team in <strong>${location}</strong>. This is a <strong>${type}</strong> position.</p>
        
        <h3>Responsibilities</h3>
        <ul>
            ${responsibilitiesList}
        </ul>

        <h3>Requirements</h3>
        <ul>
            ${requirementsList}
        </ul>

        <p>If you are passionate about the hospitality industry and meet the requirements above, we would love to hear from you!</p>
    `;
}
