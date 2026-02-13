<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.ArenaSession" %>
<%@ page import="com.examora.model.ArenaParticipant" %>
<%@ page import="com.examora.model.Question" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    ArenaSession arenaSession = (ArenaSession) request.getAttribute("arenaSession");
    ArenaParticipant participant = (ArenaParticipant) request.getAttribute("participant");
    Question currentQuestion = (Question) request.getAttribute("currentQuestion");
    List<ArenaParticipant> leaderboard = (List<ArenaParticipant>) request.getAttribute("leaderboard");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Arena - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
    <style>
        .arena-timer {
            font-size: 3rem;
            font-weight: bold;
            font-family: 'Courier New', monospace;
        }
        .arena-timer.warning {
            color: var(--danger-color);
            animation: pulse 0.5s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .option-btn {
            transition: all 0.2s ease;
        }
        .option-btn:hover:not(:disabled) {
            transform: translateX(5px);
            border-color: var(--primary-color);
        }
        .option-btn.selected {
            background-color: rgba(67, 97, 238, 0.1);
            border-color: var(--primary-color);
        }
        .option-btn.correct {
            background-color: rgba(6, 214, 160, 0.2);
            border-color: var(--success-color);
        }
        .option-btn.incorrect {
            background-color: rgba(239, 71, 111, 0.2);
            border-color: var(--danger-color);
        }
        .option-btn:disabled {
            cursor: not-allowed;
            opacity: 0.7;
        }
    </style>
</head>
<body class="bg-light">
    <!-- Top Bar -->
    <nav class="navbar navbar-dark bg-arena-gradient sticky-top">
        <div class="container-fluid">
            <div class="d-flex align-items-center text-white">
                <i class="bi bi-trophy me-2"></i>
                <span class="fw-bold">Arena</span>
                <span class="badge bg-light text-dark ms-3"><%= arenaSession.getCode() %></span>
            </div>
            <div class="d-flex align-items-center">
                <div class="text-white me-4">
                    <small>Skor Anda</small>
                    <div class="fw-bold" id="myScore"><%= participant.getScore() %> pts</div>
                </div>
                <span class="text-white">
                    <i class="bi bi-person-circle me-1"></i><%= currentUser.getName() %>
                </span>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Main Content - Question Area -->
            <div class="col-lg-8 py-4">
                <!-- Timer and Progress -->
                <div class="card mb-4">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-md-4 text-center">
                                <div class="arena-timer text-arena" id="timer"><%= arenaSession.getQuestionTime() %></div>
                                <small class="text-muted">detik tersisa</small>
                            </div>
                            <div class="col-md-8">
                                <div class="d-flex justify-content-between mb-2">
                                    <span>Soal <span id="currentQuestionNum"><%= arenaSession.getCurrentQuestion() + 1 %></span> dari <span id="totalQuestions"><%= arenaSession.getTotalQuestions() %></span></span>
                                </div>
                                <div class="progress" style="height: 10px;">
                                    <div class="progress-bar bg-arena" role="progressbar" id="progressBar"
                                         style="width: <%= (arenaSession.getCurrentQuestion() + 1) * 100 / arenaSession.getTotalQuestions() %>%"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Question Card -->
                <div class="card shadow-sm" id="questionCard">
                    <div class="card-header bg-arena-gradient text-white">
                        <h5 class="mb-0">
                            <i class="bi bi-question-circle me-2"></i>
                            Pertanyaan
                        </h5>
                    </div>
                    <div class="card-body">
                        <div id="questionText" class="fs-5 mb-4">
                            <%= currentQuestion != null ? currentQuestion.getQuestionText() : "Loading..." %>
                        </div>

                        <div id="optionsContainer">
                            <% if (currentQuestion != null) { %>
                            <button type="button" class="btn btn-outline-secondary btn-lg w-100 text-start option-btn mb-3"
                                    data-option="A" onclick="selectAnswer('A')">
                                <span class="badge bg-secondary me-3">A</span>
                                <%= currentQuestion.getOptionA() %>
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-lg w-100 text-start option-btn mb-3"
                                    data-option="B" onclick="selectAnswer('B')">
                                <span class="badge bg-secondary me-3">B</span>
                                <%= currentQuestion.getOptionB() %>
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-lg w-100 text-start option-btn mb-3"
                                    data-option="C" onclick="selectAnswer('C')">
                                <span class="badge bg-secondary me-3">C</span>
                                <%= currentQuestion.getOptionC() %>
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-lg w-100 text-start option-btn"
                                    data-option="D" onclick="selectAnswer('D')">
                                <span class="badge bg-secondary me-3">D</span>
                                <%= currentQuestion.getOptionD() %>
                            </button>
                            <% } %>
                        </div>

                        <!-- Feedback Area -->
                        <div id="feedbackArea" class="mt-4" style="display: none;">
                            <div id="feedbackContent"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sidebar - Leaderboard -->
            <div class="col-lg-4 py-4">
                <div class="card sticky-top" style="top: 80px;">
                    <div class="card-header bg-arena-gradient text-white">
                        <h5 class="mb-0"><i class="bi bi-trophy me-2"></i>Leaderboard</h5>
                    </div>
                    <div class="card-body p-0" style="max-height: calc(100vh - 150px); overflow-y: auto;">
                        <div id="leaderboardList" class="list-group list-group-flush">
                            <% if (leaderboard != null && !leaderboard.isEmpty()) {
                                int rank = 1;
                                for (ArenaParticipant p : leaderboard) { %>
                            <div class="list-group-item d-flex justify-content-between align-items-center <%= p.getUserId() == currentUser.getId() ? "bg-light" : "" %>">
                                <div class="d-flex align-items-center">
                                    <span class="badge <%= rank == 1 ? "bg-warning text-dark" :
                                        rank == 2 ? "bg-secondary" : rank == 3 ? "bg-danger" : "bg-light text-dark border" %> me-3"
                                          style="width: 30px;"><%= rank %></span>
                                    <div>
                                        <div class="fw-bold <%= p.getUserId() == currentUser.getId() ? "text-arena" : "" %>">
                                            <%= p.getUserName() %>
                                            <% if (p.getUserId() == currentUser.getId()) { %>
                                            <i class="bi bi-person-fill ms-1"></i>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                                <span class="badge bg-arena fs-6"><%= p.getScore() %> pts</span>
                            </div>
                            <% rank++;
                                }
                            } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const sessionId = <%= arenaSession.getId() %>;
        const participantId = <%= participant.getId() %>;
        const userId = <%= currentUser.getId() %>;
        const userName = '<%= currentUser.getName() %>';
        const questionTime = <%= arenaSession.getQuestionTime() %>;
        const currentQuestionId = <%= currentQuestion != null ? currentQuestion.getId() : 0 %>;

        let websocket;
        let timer;
        let timeRemaining = questionTime;
        let currentQuestionIndex = <%= arenaSession.getCurrentQuestion() %>;
        let totalQuestions = <%= arenaSession.getTotalQuestions() %>;
        let myScore = <%= participant.getScore() %>;
        let hasAnswered = false;
        let questionStartTime = Date.now();

        function initWebSocket() {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = `${protocol}//${window.location.host}${getContextPath()}/arena/${sessionId}`;

            websocket = new WebSocket(wsUrl);

            websocket.onopen = function() {
                console.log('WebSocket connected');
                websocket.send(JSON.stringify({
                    type: 'join',
                    participantId: participantId,
                    userId: userId,
                    userName: userName
                }));
                startTimer();
            };

            websocket.onmessage = function(event) {
                const data = JSON.parse(event.data);
                handleWebSocketMessage(data);
            };

            websocket.onclose = function() {
                console.log('WebSocket disconnected');
                setTimeout(initWebSocket, 3000);
            };

            websocket.onerror = function(error) {
                console.error('WebSocket error:', error);
            };
        }

        function getContextPath() {
            return '<%= request.getContextPath() %>';
        }

        function handleWebSocketMessage(data) {
            console.log('Received:', data);

            switch(data.type) {
                case 'question':
                    loadNewQuestion(data);
                    break;
                case 'leaderboard':
                    updateLeaderboard(data.data);
                    break;
                case 'answerConfirmed':
                    showAnswerFeedback(data);
                    break;
                case 'sessionEnded':
                    window.location.href = '../ArenaServlet?action=result&id=' + sessionId;
                    break;
                case 'sessionPaused':
                    pauseTimer();
                    break;
                case 'sessionResumed':
                    resumeTimer();
                    break;
            }
        }

        function startTimer() {
            timeRemaining = questionTime;
            questionStartTime = Date.now();
            hasAnswered = false;
            updateTimerDisplay();

            timer = setInterval(function() {
                timeRemaining--;
                updateTimerDisplay();

                if (timeRemaining <= 0) {
                    clearInterval(timer);
                    timeUp();
                }
            }, 1000);
        }

        function updateTimerDisplay() {
            const timerEl = document.getElementById('timer');
            timerEl.textContent = timeRemaining;

            if (timeRemaining <= 5) {
                timerEl.classList.add('warning');
            } else {
                timerEl.classList.remove('warning');
            }
        }

        function pauseTimer() {
            if (timer) clearInterval(timer);
        }

        function resumeTimer() {
            startTimer();
        }

        function timeUp() {
            if (!hasAnswered) {
                // Auto-submit with no answer
                disableOptions();
                showFeedback(false, null, 0);
            }
        }

        function selectAnswer(answer) {
            if (hasAnswered) return;

            hasAnswered = true;
            clearInterval(timer);

            const timeTaken = Date.now() - questionStartTime;

            // Highlight selected
            document.querySelectorAll('.option-btn').forEach(btn => {
                btn.classList.remove('selected');
                if (btn.dataset.option === answer) {
                    btn.classList.add('selected');
                }
            });

            disableOptions();

            // Send answer to server
            websocket.send(JSON.stringify({
                type: 'answer',
                sessionId: sessionId,
                participantId: participantId,
                questionId: currentQuestionId,
                answer: answer,
                timeTaken: timeTaken
            }));
        }

        function disableOptions() {
            document.querySelectorAll('.option-btn').forEach(btn => {
                btn.disabled = true;
            });
        }

        function showAnswerFeedback(data) {
            const isCorrect = data.isCorrect;
            const correctAnswer = data.correctAnswer;
            const scoreEarned = data.scoreEarned;

            // Update my score
            myScore += scoreEarned;
            document.getElementById('myScore').textContent = myScore + ' pts';

            // Show correct/incorrect
            document.querySelectorAll('.option-btn').forEach(btn => {
                if (btn.dataset.option === correctAnswer) {
                    btn.classList.add('correct');
                } else if (btn.classList.contains('selected') && !isCorrect) {
                    btn.classList.add('incorrect');
                }
            });

            showFeedback(isCorrect, correctAnswer, scoreEarned);
        }

        function showFeedback(isCorrect, correctAnswer, scoreEarned) {
            const feedbackArea = document.getElementById('feedbackArea');
            const feedbackContent = document.getElementById('feedbackContent');

            let html = '';
            if (isCorrect) {
                html = `
                    <div class="alert alert-success mb-0">
                        <h5 class="alert-heading"><i class="bi bi-check-circle me-2"></i>Benar!</h5>
                        <p class="mb-0">Anda mendapatkan <strong>+${scoreEarned} poin</strong></p>
                    </div>
                `;
            } else {
                html = `
                    <div class="alert alert-danger mb-0">
                        <h5 class="alert-heading"><i class="bi bi-x-circle me-2"></i>Salah!</h5>
                        <p class="mb-0">Jawaban benar: <strong>${correctAnswer || '-'}</strong></p>
                    </div>
                `;
            }

            feedbackContent.innerHTML = html;
            feedbackArea.style.display = 'block';
        }

        function loadNewQuestion(data) {
            currentQuestionIndex = data.questionIndex;
            const question = data.data;

            // Update UI
            document.getElementById('currentQuestionNum').textContent = currentQuestionIndex + 1;
            document.getElementById('progressBar').style.width = ((currentQuestionIndex + 1) * 100 / totalQuestions) + '%';
            document.getElementById('questionText').textContent = question.questionText;

            // Update options
            const optionsHtml = `
                <button type="button" class="btn btn-outline-secondary btn-lg w-100 text-start option-btn mb-3"
                        data-option="A" onclick="selectAnswer('A')">
                    <span class="badge bg-secondary me-3">A</span>${question.optionA}
                </button>
                <button type="button" class="btn btn-outline-secondary btn-lg w-100 text-start option-btn mb-3"
                        data-option="B" onclick="selectAnswer('B')">
                    <span class="badge bg-secondary me-3">B</span>${question.optionB}
                </button>
                <button type="button" class="btn btn-outline-secondary btn-lg w-100 text-start option-btn mb-3"
                        data-option="C" onclick="selectAnswer('C')">
                    <span class="badge bg-secondary me-3">C</span>${question.optionC}
                </button>
                <button type="button" class="btn btn-outline-secondary btn-lg w-100 text-start option-btn"
                        data-option="D" onclick="selectAnswer('D')">
                    <span class="badge bg-secondary me-3">D</span>${question.optionD}
                </button>
            `;
            document.getElementById('optionsContainer').innerHTML = optionsHtml;
            document.getElementById('feedbackArea').style.display = 'none';

            // Reset state
            hasAnswered = false;
            startTimer();
        }

        function updateLeaderboard(participants) {
            if (!participants || participants.length === 0) return;

            let html = '';
            participants.forEach((p, index) => {
                const rank = index + 1;
                const badgeClass = rank === 1 ? 'bg-warning text-dark' :
                                   rank === 2 ? 'bg-secondary' :
                                   rank === 3 ? 'bg-danger' : 'bg-light text-dark border';
                const isMe = p.userId === userId;
                const rowClass = isMe ? 'bg-light' : '';

                html += `
                    <div class="list-group-item d-flex justify-content-between align-items-center ${rowClass}">
                        <div class="d-flex align-items-center">
                            <span class="badge ${badgeClass} me-3" style="width: 30px;">${rank}</span>
                            <div>
                                <div class="fw-bold ${isMe ? 'text-arena' : ''}">
                                    ${p.userName}
                                    ${isMe ? '<i class="bi bi-person-fill ms-1"></i>' : ''}
                                </div>
                            </div>
                        </div>
                        <span class="badge bg-arena fs-6">${p.score} pts</span>
                    </div>
                `;

                // Update my score if it's me
                if (isMe) {
                    myScore = p.score;
                    document.getElementById('myScore').textContent = myScore + ' pts';
                }
            });

            document.getElementById('leaderboardList').innerHTML = html;
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            initWebSocket();
        });
    </script>
</body>
</html>
