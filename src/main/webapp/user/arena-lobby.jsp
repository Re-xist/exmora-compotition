<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.ArenaSession" %>
<%@ page import="com.examora.model.ArenaParticipant" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    ArenaSession arenaSession = (ArenaSession) request.getAttribute("arenaSession");
    ArenaParticipant participant = (ArenaParticipant) request.getAttribute("participant");
    List<ArenaParticipant> participants = (List<ArenaParticipant>) request.getAttribute("participants");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lobby Arena - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
    <style>
        .lobby-waiting {
            animation: pulse-glow 2s infinite;
        }
        @keyframes pulse-glow {
            0%, 100% { box-shadow: 0 0 0 0 rgba(255, 193, 7, 0.4); }
            50% { box-shadow: 0 0 0 20px rgba(255, 193, 7, 0); }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-arena-gradient">
        <div class="container">
            <a class="navbar-brand fw-bold" href="#">
                <i class="bi bi-trophy me-2"></i>Examora Arena
            </a>
            <div class="d-flex align-items-center text-white">
                <span class="badge bg-light text-dark fs-5"><%= arenaSession.getCode() %></span>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <!-- Waiting Card -->
                <div class="card shadow-lg border-0 lobby-waiting mb-4">
                    <div class="card-body text-center py-5">
                        <div class="spinner-border text-warning mb-4" style="width: 4rem; height: 4rem;"></div>
                        <h3>Menunggu Host...</h3>
                        <p class="text-muted mb-4">Arena akan segera dimulai. Bersiaplah!</p>

                        <div class="row justify-content-center mb-4">
                            <div class="col-auto">
                                <div class="bg-light rounded p-3 text-center">
                                    <div class="display-6 fw-bold text-arena"><%= arenaSession.getTotalQuestions() %></div>
                                    <small class="text-muted">Soal</small>
                                </div>
                            </div>
                            <div class="col-auto">
                                <div class="bg-light rounded p-3 text-center">
                                    <div class="display-6 fw-bold text-arena"><%= arenaSession.getQuestionTime() %>s</div>
                                    <small class="text-muted">Per Soal</small>
                                </div>
                            </div>
                        </div>

                        <div class="alert alert-info mb-0">
                            <i class="bi bi-info-circle me-2"></i>
                            Jangan tutup halaman ini. Anda akan diarahkan otomatis saat arena dimulai.
                        </div>
                    </div>
                </div>

                <!-- Session Info -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>Informasi Arena</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <p class="mb-2"><strong>Quiz:</strong></p>
                                <p class="text-muted"><%= arenaSession.getQuizTitle() %></p>
                            </div>
                            <div class="col-md-6">
                                <p class="mb-2"><strong>Host:</strong></p>
                                <p class="text-muted"><%= arenaSession.getHostName() %></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Participants List -->
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="bi bi-people me-2"></i>Peserta (<%= arenaSession.getParticipantCount() %>)</h5>
                        <span class="badge bg-arena">Waiting</span>
                    </div>
                    <div class="card-body p-0">
                        <div id="participantsList" class="list-group list-group-flush">
                            <% if (participants != null && !participants.isEmpty()) {
                                for (ArenaParticipant p : participants) { %>
                            <div class="list-group-item d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center">
                                    <div class="bg-arena-gradient text-white rounded-circle d-flex align-items-center justify-content-center me-3"
                                         style="width: 40px; height: 40px;">
                                        <%= p.getUserName().substring(0, 1).toUpperCase() %>
                                    </div>
                                    <div>
                                        <div class="fw-bold"><%= p.getUserName() %></div>
                                        <% if (p.getUserId() == currentUser.getId()) { %>
                                        <small class="text-success"><i class="bi bi-check-circle me-1"></i>Anda</small>
                                        <% } else { %>
                                        <small class="text-muted">Peserta</small>
                                        <% } %>
                                    </div>
                                </div>
                                <span class="badge bg-success">
                                    <i class="bi bi-circle-fill me-1" style="font-size: 8px;"></i>Online
                                </span>
                            </div>
                            <% }
                            } else { %>
                            <div class="text-center py-4 text-muted">
                                Belum ada peserta lain
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
        const participantId = <%= participant.getId() %>;
        const userId = <%= currentUser.getId() %>;
        const userName = '<%= currentUser.getName() %>';
        let websocket;

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
                case 'sessionStarted':
                    // Redirect to play page
                    window.location.href = '../ArenaServlet?action=play&sessionId=' + sessionId;
                    break;
                case 'participantJoined':
                    addParticipantToList(data);
                    break;
                case 'participantLeft':
                    removeParticipantFromList(data);
                    break;
                case 'leaderboard':
                    // Update participant count
                    break;
            }
        }

        function addParticipantToList(data) {
            const list = document.getElementById('participantsList');
            const html = `
                <div class="list-group-item d-flex justify-content-between align-items-center" id="participant-${data.participantId}">
                    <div class="d-flex align-items-center">
                        <div class="bg-arena-gradient text-white rounded-circle d-flex align-items-center justify-content-center me-3"
                             style="width: 40px; height: 40px;">
                            ${data.userName.charAt(0).toUpperCase()}
                        </div>
                        <div>
                            <div class="fw-bold">${data.userName}</div>
                            <small class="text-muted">Peserta</small>
                        </div>
                    </div>
                    <span class="badge bg-success">
                        <i class="bi bi-circle-fill me-1" style="font-size: 8px;"></i>Online
                    </span>
                </div>
            `;
            list.insertAdjacentHTML('beforeend', html);
        }

        function removeParticipantFromList(data) {
            const element = document.getElementById(`participant-${data.participantId}`);
            if (element) element.remove();
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            initWebSocket();
        });
    </script>
</body>
</html>
