<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Quiz" %>
<%@ page import="com.examora.model.Question" %>
<%@ page import="com.examora.model.Submission" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    Quiz quiz = (Quiz) request.getAttribute("quiz");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    Submission submission = (Submission) request.getAttribute("submission");
    Map<Integer, String> savedAnswers = (Map<Integer, String>) request.getAttribute("savedAnswers");

    if (quiz == null || questions == null || questions.isEmpty()) {
        response.sendRedirect("../ExamServlet?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= quiz.getTitle() %> - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
    <style>
        body { background-color: #f8f9fa; }
        .exam-header { position: fixed; top: 0; left: 0; right: 0; z-index: 1000; background: white; border-bottom: 2px solid #0d6efd; }
        .exam-content { margin-top: 100px; padding-bottom: 100px; }
        .question-nav { position: fixed; bottom: 0; left: 0; right: 0; background: white; border-top: 1px solid #dee2e6; padding: 1rem; }
        .question-btn { width: 40px; height: 40px; margin: 2px; }
        .question-btn.answered { background-color: #198754; border-color: #198754; color: white; }
        .question-btn.current { border: 3px solid #0d6efd; }
    </style>
</head>
<body oncontextmenu="return false;" onselectstart="return false;">
    <!-- Exam Header -->
    <div class="exam-header py-3">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-4">
                    <h5 class="mb-0"><i class="bi bi-journal-text me-2"></i><%= quiz.getTitle() %></h5>
                </div>
                <div class="col-md-4 text-center">
                    <div class="exam-timer" id="timer">
                        <i class="bi bi-stopwatch me-2"></i>
                        <span id="timeDisplay"><%= quiz.getDuration() %>:00</span>
                    </div>
                </div>
                <div class="col-md-4 text-end">
                    <span class="badge bg-info me-2">
                        <%= questions.size() %> Soal
                    </span>
                    <button class="btn btn-success" id="submitBtn" data-bs-toggle="modal" data-bs-target="#submitModal">
                        <i class="bi bi-send me-1"></i>Submit
                    </button>
                </div>
            </div>
            <!-- Progress Bar -->
            <div class="row mt-2">
                <div class="col-12">
                    <div class="progress" style="height: 8px;">
                        <div class="progress-bar" id="progressBar" role="progressbar" style="width: 0%"></div>
                    </div>
                    <small class="text-muted"><span id="answeredCount">0</span> dari <%= questions.size() %> soal dijawab</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Exam Content -->
    <div class="container exam-content">
        <form id="examForm">
            <input type="hidden" name="submissionId" value="<%= submission.getId() %>">
            <input type="hidden" name="timeSpent" id="timeSpent" value="0">
            <input type="hidden" name="csrfToken" id="csrfToken" value="<%= session.getAttribute("csrfToken") %>">

            <% for (int i = 0; i < questions.size(); i++) {
                Question q = questions.get(i);
                String savedAnswer = savedAnswers != null ? savedAnswers.get(q.getId()) : null;
            %>
            <div class="card mb-4 question-card" id="question-<%= i + 1 %>">
                <div class="card-header bg-white">
                    <div class="d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">
                            <span class="badge bg-primary me-2"><%= i + 1 %></span>
                            Pertanyaan #<%= i + 1 %>
                        </h5>
                    </div>
                </div>
                <div class="card-body">
                    <p class="fs-5 mb-4"><%= q.getQuestionText() %></p>
                    <div class="options">
                        <% String[] opts = {"A", "B", "C", "D"};
                           String[] values = {q.getOptionA(), q.getOptionB(), q.getOptionC(), q.getOptionD()};
                           for (int j = 0; j < opts.length; j++) {
                               boolean isSelected = opts[j].equals(savedAnswer);
                        %>
                        <div class="option-item p-3 mb-2 border rounded <%= isSelected ? "selected" : "" %>"
                             data-question="<%= q.getId() %>" data-option="<%= opts[j] %>"
                             style="cursor: pointer; transition: all 0.2s;"
                             onclick="selectOption(<%= q.getId() %>, '<%= opts[j] %>', <%= i + 1 %>, this)">
                            <input type="radio" name="question_<%= q.getId() %>" value="<%= opts[j] %>"
                                   id="q<%= q.getId() %>_<%= opts[j] %>" <%= isSelected ? "checked" : "" %> style="display: none;">
                            <label for="q<%= q.getId() %>_<%= opts[j] %>" class="d-block mb-0" style="cursor: pointer;">
                                <strong><%= opts[j] %>.</strong> <%= values[j] %>
                            </label>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </form>
    </div>

    <!-- Question Navigation -->
    <div class="question-nav">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <small class="text-muted me-2">Navigasi:</small>
                    <% for (int i = 0; i < questions.size(); i++) {
                        Question q = questions.get(i);
                        String savedAnswer = savedAnswers != null ? savedAnswers.get(q.getId()) : null;
                    %>
                    <button type="button" class="btn btn-outline-secondary question-btn <%= i == 0 ? "current" : "" %> <%= savedAnswer != null ? "answered" : "" %>"
                            id="nav-<%= i + 1 %>" onclick="scrollToQuestion(<%= i + 1 %>)">
                        <%= i + 1 %>
                    </button>
                    <% } %>
                </div>
                <div>
                    <span class="badge bg-secondary me-2">Belum dijawab</span>
                    <span class="badge bg-success">Dijawab</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Submit Modal -->
    <div class="modal fade" id="submitModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-question-circle me-2"></i>Konfirmasi Submit</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Apakah Anda yakin ingin menyelesaikan ujian ini?</p>
                    <p class="mb-0 text-muted">
                        Anda telah menjawab <strong id="modalAnsweredCount">0</strong> dari
                        <strong><%= questions.size() %></strong> soal.
                    </p>
                    <div id="unansweredWarning" class="alert alert-warning mt-3" style="display: none;">
                        <i class="bi bi-exclamation-triangle me-2"></i>
                        Masih ada soal yang belum dijawab!
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-lg me-1"></i>Batal
                    </button>
                    <button type="button" class="btn btn-success" onclick="submitExam()">
                        <i class="bi bi-send me-1"></i>Ya, Submit
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const totalQuestions = <%= questions.size() %>;
        const duration = <%= quiz.getDuration() %>; // in minutes
        let timeRemaining = duration * 60; // in seconds
        let answeredQuestions = {};
        let startTime = Date.now();
        const submissionId = <%= submission.getId() %>;

        // Initialize saved answers
        <% if (savedAnswers != null) {
            for (Map.Entry<Integer, String> entry : savedAnswers.entrySet()) { %>
        answeredQuestions[<%= entry.getKey() %>] = '<%= entry.getValue() %>';
        <% }
        } %>

        // Timer
        function updateTimer() {
            const minutes = Math.floor(timeRemaining / 60);
            const seconds = timeRemaining % 60;
            document.getElementById('timeDisplay').textContent =
                String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');

            // Warning when 5 minutes left
            if (timeRemaining <= 300) {
                document.getElementById('timer').classList.add('warning');
            }

            // Auto submit when time's up
            if (timeRemaining <= 0) {
                alert('Waktu habis! Jawaban Anda akan disubmit otomatis.');
                submitExam();
                return;
            }

            timeRemaining--;
        }

        setInterval(updateTimer, 1000);

        // Select option - only one answer per question
        function selectOption(questionId, option, questionNumber, element) {
            // Remove selected class from all options for this question
            const options = document.querySelectorAll('[data-question="' + questionId + '"]');
            options.forEach(el => {
                el.classList.remove('selected');
                el.style.backgroundColor = '';
                el.style.borderColor = '';
            });

            // Add selected class to clicked option
            element.classList.add('selected');
            element.style.backgroundColor = '#cfe2ff';
            element.style.borderColor = '#0d6efd';

            // Update radio button
            const radio = document.getElementById('q' + questionId + '_' + option);
            if (radio) {
                radio.checked = true;
            }

            // Save answer locally
            answeredQuestions[questionId] = option;
            updateProgress();
            updateNavigation(questionNumber);

            // Save to server via AJAX
            saveAnswerToServer(questionId, option);
        }

        // Save answer to server
        function saveAnswerToServer(questionId, selectedAnswer) {
            const csrfToken = document.getElementById('csrfToken').value;
            fetch('../ExamServlet?action=saveAnswer', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'submissionId=' + submissionId + '&questionId=' + questionId + '&selectedAnswer=' + selectedAnswer + '&csrfToken=' + encodeURIComponent(csrfToken)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    console.log('Answer saved for question ' + questionId);
                } else {
                    console.error('Failed to save answer:', data.message);
                }
            })
            .catch(error => {
                console.error('Error saving answer:', error);
            });
        }

        // Update progress
        function updateProgress() {
            const answered = Object.keys(answeredQuestions).length;
            document.getElementById('answeredCount').textContent = answered;
            document.getElementById('modalAnsweredCount').textContent = answered;

            const percentage = (answered / totalQuestions) * 100;
            document.getElementById('progressBar').style.width = percentage + '%';
            document.getElementById('progressBar').setAttribute('aria-valuenow', percentage);

            // Show warning if not all questions answered
            document.getElementById('unansweredWarning').style.display =
                answered < totalQuestions ? 'block' : 'none';
        }

        // Update navigation button
        function updateNavigation(questionNumber) {
            const btn = document.getElementById('nav-' + questionNumber);
            if (btn) {
                btn.classList.remove('btn-outline-secondary');
                btn.classList.add('answered', 'btn-success');
            }
        }

        // Scroll to question
        function scrollToQuestion(num) {
            // Remove current class from all buttons
            document.querySelectorAll('.question-btn').forEach(b => b.classList.remove('current'));
            // Add current class to clicked button
            const currentBtn = document.getElementById('nav-' + num);
            if (currentBtn) {
                currentBtn.classList.add('current');
            }
            // Scroll to question
            const questionEl = document.getElementById('question-' + num);
            if (questionEl) {
                questionEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }

        // Submit exam
        function submitExam() {
            // Disable beforeunload warning before submitting
            isSubmitting = true;

            const timeSpent = Math.floor((Date.now() - startTime) / 1000);
            document.getElementById('timeSpent').value = timeSpent;

            const form = document.getElementById('examForm');
            form.action = '../ExamServlet?action=submit';
            form.method = 'POST';
            form.submit();
        }

        // Flag to track if we're submitting
        let isSubmitting = false;

        // Prevent accidental page leave (but allow submit)
        window.addEventListener('beforeunload', function(e) {
            if (isSubmitting) {
                return; // Allow submit without confirmation
            }
            e.preventDefault();
            e.returnValue = '';
        });

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            updateProgress();

            // Mark already answered questions in navigation
            for (const questionId in answeredQuestions) {
                // Find question number from data attribute
                const optionEl = document.querySelector('[data-question="' + questionId + '"]');
                if (optionEl) {
                    const card = optionEl.closest('.question-card');
                    if (card) {
                        const questionNum = card.id.replace('question-', '');
                        updateNavigation(parseInt(questionNum));
                    }
                }
            }
        });

        // Disable copy-paste
        document.addEventListener('copy', e => e.preventDefault());
        document.addEventListener('paste', e => e.preventDefault());

        // Detect tab switch (optional warning)
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                console.log('Tab switch detected');
            }
        });
    </script>
</body>
</html>
