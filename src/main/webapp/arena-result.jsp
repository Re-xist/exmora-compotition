<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.ArenaSession" %>
<%@ page import="com.examora.model.ArenaParticipant" %>
<%@ page import="com.examora.service.ArenaService" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("LoginServlet");
        return;
    }

    ArenaSession arenaSession = (ArenaSession) request.getAttribute("arenaSession");
    List<ArenaParticipant> leaderboard = (List<ArenaParticipant>) request.getAttribute("leaderboard");
    ArenaParticipant participant = (ArenaParticipant) request.getAttribute("participant");
    ArenaService.ArenaStats stats = (ArenaService.ArenaStats) request.getAttribute("stats");

    // Find participant's rank
    int myRank = 0;
    if (leaderboard != null && participant != null) {
        for (int i = 0; i < leaderboard.size(); i++) {
            if (leaderboard.get(i).getUserId().equals(currentUser.getId())) {
                myRank = i + 1;
                break;
            }
        }
    }
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
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-arena-gradient">
        <div class="container">
            <a class="navbar-brand fw-bold" href="#">
                <i class="bi bi-trophy me-2"></i>Examora Arena
            </a>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container py-5">
        <!-- Header -->
        <div class="text-center mb-5">
            <div class="bg-arena-gradient text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-4"
                 style="width: 100px; height: 100px;">
                <i class="bi bi-trophy-fill" style="font-size: 3rem;"></i>
            </div>
            <h1>Arena Selesai!</h1>
            <p class="text-muted"><%= arenaSession.getQuizTitle() %></p>
        </div>

        <div class="row justify-content-center">
            <!-- My Result Card -->
            <% if (participant != null) { %>
            <div class="col-md-4 mb-4">
                <div class="card shadow-lg h-100">
                    <div class="card-header bg-arena-gradient text-white text-center">
                        <h5 class="mb-0">Hasil Anda</h5>
                    </div>
                    <div class="card-body text-center py-4">
                        <div class="mb-3">
                            <span class="badge <%= myRank == 1 ? "bg-warning text-dark" :
                                myRank == 2 ? "bg-secondary" : myRank == 3 ? "bg-danger" : "bg-light text-dark border" %> fs-2 p-3">
                                #<%= myRank %>
                            </span>
                        </div>
                        <h2 class="display-4 text-arena mb-0"><%= participant.getScore() %></h2>
                        <p class="text-muted">poin</p>

                        <% if (myRank == 1) { %>
                        <div class="alert alert-warning">
                            <i class="bi bi-trophy-fill me-2"></i>
                            <strong>Selamat! Anda juara!</strong>
                        </div>
                        <% } else if (myRank <= 3) { %>
                        <div class="alert alert-info">
                            <i class="bi bi-star-fill me-2"></i>
                            <strong>Hebat! Top 3!</strong>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Final Leaderboard -->
            <div class="<%= participant != null ? "col-md-8" : "col-md-10" %> mb-4">
                <div class="card shadow-lg">
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
                                        <th class="text-end">Skor</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (leaderboard != null && !leaderboard.isEmpty()) {
                                        int rank = 1;
                                        for (ArenaParticipant p : leaderboard) { %>
                                    <tr class="<%= p.getUserId().equals(currentUser.getId()) ? "table-primary" : "" %>">
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
                                                <div>
                                                    <div class="fw-bold">
                                                        <%= p.getUserName() %>
                                                        <% if (p.getUserId().equals(currentUser.getId())) { %>
                                                        <span class="badge bg-arena ms-1">Anda</span>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="text-end">
                                            <span class="badge bg-arena fs-6"><%= p.getScore() %> pts</span>
                                        </td>
                                    </tr>
                                    <% rank++;
                                        }
                                    } else { %>
                                    <tr>
                                        <td colspan="3" class="text-center py-4 text-muted">
                                            Tidak ada data peserta
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="row justify-content-center mb-4">
            <div class="col-md-3 col-6 mb-3">
                <div class="card text-center">
                    <div class="card-body py-3">
                        <i class="bi bi-people text-arena fs-3"></i>
                        <div class="fw-bold fs-4"><%= stats.getTotalParticipants() %></div>
                        <small class="text-muted">Peserta</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6 mb-3">
                <div class="card text-center">
                    <div class="card-body py-3">
                        <i class="bi bi-question-circle text-arena fs-3"></i>
                        <div class="fw-bold fs-4"><%= stats.getTotalQuestions() %></div>
                        <small class="text-muted">Soal</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6 mb-3">
                <div class="card text-center">
                    <div class="card-body py-3">
                        <i class="bi bi-graph-up text-arena fs-3"></i>
                        <div class="fw-bold fs-4"><%= String.format("%.0f", stats.getAverageScore()) %></div>
                        <small class="text-muted">Rata-rata Skor</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6 mb-3">
                <div class="card text-center">
                    <div class="card-body py-3">
                        <i class="bi bi-trophy text-arena fs-3"></i>
                        <div class="fw-bold fs-4"><%= stats.getHighestScore() %></div>
                        <small class="text-muted">Skor Tertinggi</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Actions -->
        <div class="text-center">
            <a href="<%= currentUser.isAdmin() ? "ArenaServlet?action=list" : "ExamServlet?action=dashboard" %>"
               class="btn btn-arena btn-lg">
                <i class="bi bi-house me-2"></i>Kembali ke Dashboard
            </a>
            <a href="ArenaServlet?action=join" class="btn btn-outline-arena btn-lg ms-2">
                <i class="bi bi-trophy me-2"></i>Main Lagi
            </a>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-light py-3 mt-auto">
        <div class="container text-center">
            <span class="text-muted">&copy; 2024 Examora. All rights reserved.</span>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
