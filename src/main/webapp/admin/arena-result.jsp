<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.ArenaSession" %>
<%@ page import="com.examora.model.ArenaParticipant" %>
<%@ page import="com.examora.service.ArenaService" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    ArenaSession arenaSession = (ArenaSession) request.getAttribute("arenaSession");
    List<ArenaParticipant> leaderboard = (List<ArenaParticipant>) request.getAttribute("leaderboard");
    ArenaParticipant participant = (ArenaParticipant) request.getAttribute("participant");
    ArenaService.ArenaStats stats = (ArenaService.ArenaStats) request.getAttribute("stats");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hasil Arena - Examora</title>
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
                <a href="../AttendanceServlet?action=list">
                    <i class="bi bi-check2-square"></i>Absensi
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
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Hasil Arena</h1>
                <p class="text-muted mb-0"><%= arenaSession.getQuizTitle() %> - <%= arenaSession.getCode() %></p>
            </div>
            <div>
                <a href="../ArenaServlet?action=list" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>Kembali
                </a>
                <button onclick="window.print()" class="btn btn-outline-primary ms-2">
                    <i class="bi bi-printer me-2"></i>Cetak
                </button>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card stat-card bg-arena-gradient text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Peserta</p>
                                <h2 class="stat-value mb-0"><%= stats.getTotalParticipants() %></h2>
                            </div>
                            <i class="bi bi-people stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-primary text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Total Soal</p>
                                <h2 class="stat-value mb-0"><%= stats.getTotalQuestions() %></h2>
                            </div>
                            <i class="bi bi-question-circle stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-success text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Rata-rata Skor</p>
                                <h2 class="stat-value mb-0"><%= String.format("%.0f", stats.getAverageScore()) %></h2>
                            </div>
                            <i class="bi bi-graph-up stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-warning text-dark">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Skor Tertinggi</p>
                                <h2 class="stat-value mb-0"><%= stats.getHighestScore() %></h2>
                            </div>
                            <i class="bi bi-trophy stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Leaderboard -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-trophy me-2"></i>Leaderboard Akhir</h5>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th style="width: 60px;">Rank</th>
                                <th>Peserta</th>
                                <th class="text-center">Status</th>
                                <th class="text-end">Skor</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (leaderboard != null && !leaderboard.isEmpty()) {
                                int rank = 1;
                                for (ArenaParticipant p : leaderboard) { %>
                            <tr>
                                <td>
                                    <span class="badge <%= rank == 1 ? "bg-warning text-dark" :
                                        rank == 2 ? "bg-secondary" : rank == 3 ? "bg-danger" : "bg-light text-dark border" %>">
                                        <%= rank %>
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="bg-arena-gradient text-white rounded-circle d-flex align-items-center justify-content-center me-2"
                                             style="width: 36px; height: 36px;">
                                            <%= p.getUserName().substring(0, 1).toUpperCase() %>
                                        </div>
                                        <div class="fw-bold">
                                            <%= p.getUserName() %>
                                        </div>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge <%= p.getIsConnected() ? "bg-success" : "bg-secondary" %>">
                                        <%= p.getIsConnected() ? "Online" : "Offline" %>
                                    </span>
                                </td>
                                <td class="text-end">
                                    <span class="badge bg-arena fs-6"><%= p.getScore() %> pts</span>
                                </td>
                            </tr>
                            <% rank++;
                                }
                            } else { %>
                            <tr>
                                <td colspan="4" class="text-center py-4 text-muted">
                                    Tidak ada data peserta
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Session Info -->
        <div class="card mt-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>Informasi Sesi</h5>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <table class="table table-sm">
                            <tr>
                                <td class="text-muted">Kode Arena</td>
                                <td class="fw-bold"><%= arenaSession.getCode() %></td>
                            </tr>
                            <tr>
                                <td class="text-muted">Quiz</td>
                                <td><%= arenaSession.getQuizTitle() %></td>
                            </tr>
                            <tr>
                                <td class="text-muted">Host</td>
                                <td><%= arenaSession.getHostName() %></td>
                            </tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <table class="table table-sm">
                            <tr>
                                <td class="text-muted">Waktu Per Soal</td>
                                <td><%= arenaSession.getQuestionTime() %> detik</td>
                            </tr>
                            <tr>
                                <td class="text-muted">Waktu Mulai</td>
                                <td><%= arenaSession.getStartedAt() != null ?
                                    arenaSession.getStartedAt().format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm")) : "-" %></td>
                            </tr>
                            <tr>
                                <td class="text-muted">Waktu Selesai</td>
                                <td><%= arenaSession.getEndedAt() != null ?
                                    arenaSession.getEndedAt().format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm")) : "-" %></td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
