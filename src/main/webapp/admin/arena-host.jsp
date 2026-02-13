<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.ArenaSession" %>
<%@ page import="com.examora.model.ArenaParticipant" %>
<%@ page import="com.examora.model.Question" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    ArenaSession arenaSession = (ArenaSession) request.getAttribute("arenaSession");
    List<ArenaParticipant> participants = (List<ArenaParticipant>) request.getAttribute("participants");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Host Panel - Examora Arena</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <!-- Sidebar -->
    <nav class="sidebar">
        <a href="../index.jsp" class="sidebar-brand">
            <i class="bi bi-journal-check me-2"></i>Examora
        </a>
        <hr class="sidebar-divider bg-white opacity-25">
        <ul class="sidebar-menu">
            <li>
                <a href="../AdminServlet?action=dashboard">
                    <i class="bi bi-speedometer2"></i>Dashboard
                </a>
            </li>
            <li>
                <a href="../QuizServlet?action=list">
                    <i class="bi bi-journal-text"></i>Kelola Quiz
                </a>
            </li>
            <li>
                <a href="../ArenaServlet?action=list" class="active">
                    <i class="bi bi-trophy"></i>Kelola Arena
                </a>
            </li>
            <li>
                <a href="../AdminServlet?action=users">
                    <i class="bi bi-people"></i>Kelola User
                </a>
            </li>
            <li>
                <a href="../AdminServlet?action=statistics">
                    <i class="bi bi-graph-up"></i>Statistik
                </a>
            </li>
            <li>
                <a href="../SettingsServlet">
                    <i class="bi bi-gear"></i>Pengaturan
                </a>
            </li>
            <li class="mt-5">
                <a href="../LogoutServlet">
                    <i class="bi bi-box-arrow-left"></i>Logout
                </a>
            </li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Host Control Panel</h1>
                <p class="text-muted mb-0"><%= arenaSession.getQuizTitle() %></p>
            </div>
            <div>
                <a href="../ArenaServlet?action=list" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>Kembali
                </a>
            </div>
        </div>

        <div class="row g-4">
            <!-- Left Column - Session Info & Controls -->
            <div class="col-md-4">
                <!-- Session Info Card -->
                <div class="card mb-4">
                    <div class="card-header bg-arena-gradient text-white">
                        <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>Info Arena</h5>
                    </div>
                    <div class="card-body text-center">
                        <h2 class="display-4 text-arena mb-3"><%= arenaSession.getCode() %></h2>
                        <p class="text-muted mb-3">Bagikan kode ini kepada peserta</p>

                        <div class="row text-center mb-3">
                            <div class="col-6">
                                <div class="border-end">
                                    <h4 class="mb-0"><%= arenaSession.getParticipantCount() %></h4>
                                    <small class="text-muted">Peserta</small>
                                </div>
                            </div>
                            <div class="col-6">
                                <div>
                                    <h4 class="mb-0"><%= arenaSession.getTotalQuestions() %></h4>
                                    <small class="text-muted">Soal</small>
                                </div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <span class="badge <%= "waiting".equals(arenaSession.getStatus()) ? "bg-warning text-dark" :
                                "active".equals(arenaSession.getStatus()) ? "bg-success" :
                                "paused".equals(arenaSession.getStatus()) ? "bg-info" : "bg-secondary" %> fs-6">
                                <%= "waiting".equals(arenaSession.getStatus()) ? "Menunggu" :
                                    "active".equals(arenaSession.getStatus()) ? "Berjalan" :
                                    "paused".equals(arenaSession.getStatus()) ? "Dijeda" : "Selesai" %>
                            </span>
                        </div>

                        <p class="text-muted small mb-0">
                            <i class="bi bi-clock me-1"></i>
                            <%= arenaSession.getQuestionTime() %> detik per soal
                        </p>
                    </div>
                </div>

                <!-- Control Panel -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-sliders me-2"></i>Kontrol</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-grid gap-2" id="controlButtons">
                            <% if ("waiting".equals(arenaSession.getStatus())) { %>
                            <button type="button" class="btn btn-success btn-lg" onclick="startArena()">
                                <i class="bi bi-play-fill me-2"></i>Mulai Arena
                            </button>
                            <% } else if ("active".equals(arenaSession.getStatus())) { %>
                            <button type="button" class="btn btn-warning" onclick="pauseArena()">
                                <i class="bi bi-pause-fill me-2"></i>Pause
                            </button>
                            <button type="button" class="btn btn-primary" onclick="nextQuestion()">
                                <i class="bi bi-skip-forward-fill me-2"></i>Soal Berikutnya
                            </button>
                            <button type="button" class="btn btn-danger" onclick="endArena()">
                                <i class="bi bi-stop-fill me-2"></i>Akhiri Arena
                            </button>
                            <% } else if ("paused".equals(arenaSession.getStatus())) { %>
                            <button type="button" class="btn btn-success" onclick="resumeArena()">
                                <i class="bi bi-play-fill me-2"></i>Lanjutkan
                            </button>
                            <button type="button" class="btn btn-danger" onclick="endArena()">
                                <i class="bi bi-stop-fill me-2"></i>Akhiri Arena
                            </button>
                            <% } else { %>
                            <a href="../ArenaServlet?action=result&id=<%= arenaSession.getId() %>"
                               class="btn btn-info btn-lg">
                                <i class="bi bi-bar-chart me-2"></i>Lihat Hasil
                            </a>
                            <% } %>
                        </div>

                        <!-- Progress -->
                        <% if (!"waiting".equals(arenaSession.getStatus())) { %>
                        <div class="mt-4">
                            <label class="form-label small text-muted">Progress Soal</label>
                            <div class="progress" style="height: 10px;">
                                <div class="progress-bar bg-arena" role="progressbar"
                                     style="width: <%= (arenaSession.getCurrentQuestion() + 1) * 100 / arenaSession.getTotalQuestions() %>%"></div>
                            </div>
                            <small class="text-muted">
                                Soal <%= arenaSession.getCurrentQuestion() + 1 %> dari <%= arenaSession.getTotalQuestions() %>
                            </small>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Middle Column - Current Question -->
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-question-circle me-2"></i>Soal Saat Ini</h5>
                    </div>
                    <div class="card-body">
                        <div id="questionDisplay">
                            <% if ("active".equals(arenaSession.getStatus()) || "paused".equals(arenaSession.getStatus())) {
                                int currentIdx = arenaSession.getCurrentQuestion();
                                if (questions != null && currentIdx >= 0 && currentIdx < questions.size()) {
                                    Question q = questions.get(currentIdx);
                            %>
                            <div class="mb-3">
                                <span class="badge bg-arena mb-2">Soal <%= currentIdx + 1 %></span>
                                <p class="fw-bold"><%= q.getQuestionText() %></p>
                            </div>
                            <div class="list-group list-group-flush">
                                <div class="list-group-item d-flex align-items-center">
                                    <span class="badge bg-secondary me-3">A</span>
                                    <%= q.getOptionA() %>
                                </div>
                                <div class="list-group-item d-flex align-items-center">
                                    <span class="badge bg-secondary me-3">B</span>
                                    <%= q.getOptionB() %>
                                </div>
                                <div class="list-group-item d-flex align-items-center">
                                    <span class="badge bg-secondary me-3">C</span>
                                    <%= q.getOptionC() %>
                                </div>
                                <div class="list-group-item d-flex align-items-center">
                                    <span class="badge bg-secondary me-3">D</span>
                                    <%= q.getOptionD() %>
                                </div>
                            </div>
                            <div class="alert alert-success mt-3 mb-0">
                                <strong>Jawaban Benar: <%= q.getCorrectAnswer() %></strong>
                            </div>
                            <%
                                }
                            } else { %>
                            <div class="text-center py-5 text-muted">
                                <i class="bi bi-hourglass display-4 d-block mb-3"></i>
                                <p>Menunggu arena dimulai...</p>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column - Participants & Leaderboard -->
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="bi bi-trophy me-2"></i>Peserta (<span id="participantCount"><%= arenaSession.getParticipantCount() %></span>)</h5>
                    </div>
                    <div class="card-body p-0">
                        <div id="leaderboardDisplay" class="list-group list-group-flush">
                            <% if (participants != null && !participants.isEmpty()) {
                                int rank = 1;
                                for (ArenaParticipant p : participants) { %>
                            <div class="list-group-item d-flex justify-content-between align-items-center" id="host-participant-<%= p.getId() %>">
                                <div class="d-flex align-items-center">
                                    <span class="badge <%= rank == 1 ? "bg-warning text-dark" :
                                        rank == 2 ? "bg-secondary" : rank == 3 ? "bg-danger" : "bg-light text-dark" %> me-3" style="width: 30px;">
                                        <%= rank %>
                                    </span>
                                    <div>
                                        <div class="fw-bold"><%= p.getUserName() %></div>
                                        <small class="text-muted <%= p.getIsConnected() ? "text-success" : "text-danger" %>">
                                            <i class="bi bi-circle-fill me-1" style="font-size: 8px;"></i>
                                            <%= p.getIsConnected() ? "Online" : "Offline" %>
                                        </small>
                                    </div>
                                </div>
                                <span class="badge bg-arena fs-6"><%= p.getScore() %> pts</span>
                            </div>
                            <% rank++;
                                }
                            } else { %>
                            <div class="text-center py-5 text-muted" id="noParticipantsHost">
                                <i class="bi bi-people display-4 d-block mb-3"></i>
                                <p>Belum ada peserta</p>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const sessionId = <%= arenaSession.getId() %>;
        const hostId = <%= currentUser.getId() %>;
        const contextPath = '<%= request.getContextPath() %>';
        let websocket;

        // Initialize WebSocket connection
        function initWebSocket() {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = protocol + '//' + window.location.host + contextPath + '/arena/' + sessionId;

            websocket = new WebSocket(wsUrl);

            websocket.onopen = function() {
                console.log('WebSocket connected');
                // Send host join message
                websocket.send(JSON.stringify({
                    type: 'join',
                    participantId: 0, // Host doesn't have participant ID
                    userId: hostId,
                    userName: <%= new com.google.gson.Gson().toJson(currentUser.getName()) %>
                }));
            };

            websocket.onmessage = function(event) {
                const data = JSON.parse(event.data);
                handleWebSocketMessage(data);
            };

            websocket.onclose = function() {
                console.log('WebSocket disconnected');
                // Try to reconnect after 3 seconds
                setTimeout(initWebSocket, 3000);
            };

            websocket.onerror = function(error) {
                console.error('WebSocket error:', error);
            };
        }

        function handleWebSocketMessage(data) {
            console.log('Received:', data);

            switch(data.type) {
                case 'leaderboard':
                    updateLeaderboard(data.data);
                    break;
                case 'question':
                    updateQuestion(data);
                    break;
                case 'participantJoined':
                    showNotification(data.userName + ' bergabung', 'info');
                    updateParticipantCount(1);
                    break;
                case 'participantLeft':
                    showNotification(data.userName + ' keluar', 'warning');
                    updateParticipantCount(-1);
                    break;
                case 'sessionStarted':
                    showNotification('Arena dimulai!', 'success');
                    setTimeout(() => location.reload(), 1000);
                    break;
                case 'sessionPaused':
                    showNotification('Arena dijeda', 'warning');
                    break;
                case 'sessionResumed':
                    showNotification('Arena dilanjutkan', 'info');
                    break;
                case 'sessionEnded':
                    showNotification('Arena selesai!', 'success');
                    setTimeout(() => location.reload(), 1000);
                    break;
            }
        }

        function updateParticipantCount(delta) {
            const countEl = document.getElementById('participantCount');
            const currentCount = parseInt(countEl.textContent) || 0;
            countEl.textContent = currentCount + delta;
        }

        function updateLeaderboard(participants) {
            const container = document.getElementById('leaderboardDisplay');
            if (!participants || participants.length === 0) {
                container.innerHTML = '<div class="text-center py-5 text-muted"><i class="bi bi-people display-4 d-block mb-3"></i><p>Belum ada peserta</p></div>';
                return;
            }

            // Remove "no participants" message if exists
            const noMsg = document.getElementById('noParticipantsHost');
            if (noMsg) noMsg.remove();

            let html = '';
            participants.forEach((p, index) => {
                const rank = index + 1;
                const badgeClass = rank === 1 ? 'bg-warning text-dark' :
                                   rank === 2 ? 'bg-secondary' :
                                   rank === 3 ? 'bg-danger' : 'bg-light text-dark';
                const statusClass = p.isConnected ? 'text-success' : 'text-danger';
                const statusText = p.isConnected ? 'Online' : 'Offline';
                const displayName = p.userName || p.user_name || 'Unknown';

                html += `
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                        <div class="d-flex align-items-center">
                            <span class="badge ${badgeClass} me-3" style="width: 30px;">${rank}</span>
                            <div>
                                <div class="fw-bold">${displayName}</div>
                                <small class="text-muted ${statusClass}">
                                    <i class="bi bi-circle-fill me-1" style="font-size: 8px;"></i>${statusText}
                                </small>
                            </div>
                        </div>
                        <span class="badge bg-arena fs-6">${p.score != null ? p.score : 0} pts</span>
                    </div>
                `;
            });
            container.innerHTML = html;
        }

        function updateQuestion(data) {
            // This would update the question display in real-time
            // For now, we'll reload on question changes
        }

        function showNotification(message, type) {
            // Simple alert for now, could be replaced with toast
            console.log(`[${type}] ${message}`);
        }

        // Control functions
        function startArena() {
            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                alert('WebSocket tidak terhubung');
                return;
            }
            websocket.send(JSON.stringify({
                type: 'start',
                hostId: hostId
            }));
        }

        function pauseArena() {
            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                alert('WebSocket tidak terhubung');
                return;
            }
            websocket.send(JSON.stringify({
                type: 'pause',
                hostId: hostId
            }));
        }

        function resumeArena() {
            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                alert('WebSocket tidak terhubung');
                return;
            }
            websocket.send(JSON.stringify({
                type: 'resume',
                hostId: hostId
            }));
        }

        function nextQuestion() {
            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                alert('WebSocket tidak terhubung');
                return;
            }
            websocket.send(JSON.stringify({
                type: 'next',
                hostId: hostId
            }));
        }

        function endArena() {
            if (!confirm('Yakin ingin mengakhiri arena?')) return;

            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                alert('WebSocket tidak terhubung');
                return;
            }
            websocket.send(JSON.stringify({
                type: 'end',
                hostId: hostId
            }));
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            initWebSocket();
        });
    </script>
</body>
</html>
