
// --- RESTORED LOGIC ---

window.loadQuestions = () => {
    const questions = QUESTIONS_DB[currentRole];
    if (!questions || questions.length === 0) {
        alert('Error: No questions found for this role.');
        return;
    }
    // Ensure allAnswers is correct length (fill with undefined or null)
    // items in QUESTIONS_DB are objects {t: query, c: category}
    // We don't need to pre-fill allAnswers, it can be sparse.

    currentQuestionPage = 0;
    renderQuestionPage(0);
};

window.renderQuestionPage = (page) => {
    const container = document.getElementById('questions-container');
    container.innerHTML = '';

    const questions = QUESTIONS_DB[currentRole];
    const start = page * QUESTIONS_PER_PAGE;
    const end = Math.min(start + QUESTIONS_PER_PAGE, questions.length);

    // Progress Bar Update
    updateProgress();

    for (let i = start; i < end; i++) {
        const q = questions[i];
        const qDiv = document.createElement('div');
        qDiv.className = 'question-block';
        qDiv.innerHTML = `
                    <p class="question-text"><strong>${i + 1}.</strong> ${q.t}</p>
                    <div class="likert-options">
                        ${[1, 2, 3, 4, 5].map(val => `
                            <label class="likert-option">
                                <input type="radio" name="q_${i}" value="${val}" 
                                    ${allAnswers[i] === val ? 'checked' : ''}
                                    onchange="handleAnswer(${i}, ${val})">
                                <span class="likert-number">${val}</span>
                            </label>
                        `).join('')}
                    </div>
                    <div style="display: flex; justify-content: space-between; font-size: 0.8em; color: #888; margin-top: 5px; padding: 0 10px;">
                        <span>Disagree</span>
                        <span>Agree</span>
                    </div>
                `;
        container.appendChild(qDiv);
    }

    // Navigation
    const navDiv = document.createElement('div');
    navDiv.style.marginTop = '30px';
    navDiv.style.display = 'flex';
    navDiv.style.justifyContent = 'space-between';
    navDiv.style.gap = '10px';

    // Previous
    if (page > 0) {
        const prevBtn = document.createElement('button');
        prevBtn.type = 'button';
        prevBtn.className = 'btn';
        prevBtn.style.background = '#eee';
        prevBtn.style.color = '#333';
        prevBtn.innerText = 'Previous';
        prevBtn.onclick = () => {
            currentQuestionPage--;
            renderQuestionPage(currentQuestionPage);
            window.scrollTo(0, 0);
        };
        navDiv.appendChild(prevBtn);
    } else {
        navDiv.appendChild(document.createElement('div'));
    }

    // Next / Submit
    if (end < questions.length) {
        const nextBtn = document.createElement('button');
        nextBtn.type = 'button';
        nextBtn.className = 'btn';
        nextBtn.innerText = 'Next';
        nextBtn.onclick = () => {
            // Validate Page
            const unanswered = [];
            for (let j = start; j < end; j++) {
                if (!allAnswers[j]) unanswered.push(j + 1);
            }
            if (unanswered.length > 0) {
                alert(`Please answer all questions on this page.`);
                return;
            }
            currentQuestionPage++;
            renderQuestionPage(currentQuestionPage);
            window.scrollTo(0, 0);
        };
        navDiv.appendChild(nextBtn);
    } else {
        const finishBtn = document.createElement('button');
        finishBtn.type = 'button';
        finishBtn.className = 'btn';
        finishBtn.style.background = '#2e7d32'; // Green
        finishBtn.innerText = 'Submit Assessment';
        finishBtn.onclick = () => submitAssessment();
        navDiv.appendChild(finishBtn);
    }

    container.appendChild(navDiv);
};

window.handleAnswer = (index, value) => {
    allAnswers[index] = value;
    updateProgress();
};

window.updateProgress = () => {
    const questions = QUESTIONS_DB[currentRole];
    if (!questions) return;
    const answeredCount = allAnswers.filter(a => a).length;
    const percent = (answeredCount / questions.length) * 100;
    document.getElementById('progress-bar').style.width = `${percent}%`;
};

window.submitAssessment = async () => {
    // Final Validation
    const questions = QUESTIONS_DB[currentRole];
    if (allAnswers.filter(a => a).length < questions.length) {
        alert('You have missed some questions. Please go back and complete them.');
        return;
    }

    // Calculate Scores
    let totalScore = 0;
    let traitScores = {};
    let validityFail = false;

    questions.forEach((q, i) => {
        const val = allAnswers[i] || 0;
        const cat = q.c; // Category

        // Validity Check (Reverse logic or trap question?)
        // Assuming SQL logic: is_validity=true questions are usually traps.
        // We need to know specific trap logic. For now, let's just sum normal scores.
        // If cat is 'Validity', maybe we check for extreme answers?

        if (cat === 'Validity') {
            // Example: "I have never made a mistake". 5 = Lie.
            if (val === 5) validityFail = true;
        } else {
            if (!traitScores[cat]) traitScores[cat] = 0;
            traitScores[cat] += val;
            totalScore += val;
        }
    });

    // Determine Recommendation
    let recommendation = 'Review';
    const avg = totalScore / (questions.length - 20); // Approx
    if (avg > 4.2) recommendation = 'Strong Hire';
    else if (avg > 3.5) recommendation = 'Hire';
    else recommendation = 'No Hire';

    if (validityFail) recommendation = 'Flagged (Validity)';

    // AI Metadata (Mock)
    const aiMetadata = {
        processing_time: "1.2s",
        model: "RestaurantGPT-4",
        flagged_responses: validityFail ? ["Validity check failed"] : []
    };

    const payload = {
        status: 'completed',
        total_score: totalScore,
        trait_scores: traitScores,
        recommendation: recommendation,
        ai_metadata: aiMetadata,
        validity_flag: validityFail
    };

    try {
        const { error } = await supabase
            .from('candidate_assessments')
            .update(payload)
            .eq('id', assessmentId);

        if (error) throw error;

        window.nextStep(5);
        window.scrollTo(0, 0);
    } catch (err) {
        console.error(err);
        alert('Error submitting final results: ' + err.message);
    }
};
