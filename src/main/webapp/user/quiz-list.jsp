<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Quiz" %>
<%@ page import="com.examora.model.Submission" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    Map<Integer, Submission> userSubmissions = (Map<Integer, Submission>) request.getAttribute("userSubmissions");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz Tersedia - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand fw-bold" href="../ExamServlet?action=dashboard">
                <i class="bi bi-journal-check me-2"></i>Examora
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="../ExamServlet?action=dashboard">
                            <i class="bi bi-house me-1"></i>Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="../ExamServlet?action=list">
                            <i class="bi bi-journal-text me-1"></i>Quiz Tersedia
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../ExamServlet?action=history">
                            <i class="bi bi-clock-history me-1"></i>Riwayat
                        </a>
                    </li>
                </ul>
                <div class="d-flex align-items-center">
                    <span class="text-white me-3">
                        <i class="bi bi-person-circle me-1"></i><%= currentUser.getName() %>
                    </span>
                    <a href="../LogoutServlet" class="btn btn-outline-light btn-sm">
                        <i class="bi bi-box-arrow-left me-1"></i>Logout
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container py-4">
        <h2 class="mb-4"><i class="bi bi-journal-text me-2"></i>Quiz Tersedia</h2>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (quizzes != null && !quizzes.isEmpty()) { %>
        <div class="row g-4">
            <% for (Quiz quiz : quizzes) {
                Submission sub = userSubmissions != null ? userSubmissions.get(quiz.getId()) : null;
                boolean hasSubmitted = sub != null && sub.isCompleted();
            %>
            <div class="col-md-6 col-lg-4">
                <div class="card h-100">
                    <div class="card-header bg-<%= hasSubmitted ? "success" : "primary" %> text-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <span><%= quiz.getTitle() %></span>
                            <% if (hasSubmitted) { %>
                            <span class="badge bg-light text-success">Selesai</span>
                            <% } else { %>
                            <span class="badge bg-light text-primary">Tersedia</span>
                            <% } %>
                        </div>
                    </div>
                    <div class="card-body">
                        <p class="card-text">
                            <%= quiz.getDescription() != null ? quiz.getDescription() : "Tidak ada deskripsi" %>
                        </p>
                        <hr>
                        <div class="row text-center mb-3">
                            <div class="col-4">
                                <i class="bi bi-clock d-block fs-4 text-muted"></i>
                                <small><%= quiz.getDuration() %> menit</small>
                            </div>
                            <div class="col-4">
                                <i class="bi bi-question-circle d-block fs-4 text-muted"></i>
                                <small><%= quiz.getQuestionCount() %> soal</small>
                            </div>
                            <div class="col-4">
                                <% if (quiz.getDeadline() != null) { %>
                                <i class="bi bi-calendar-event d-block fs-4 text-warning"></i>
                                <small><%= quiz.getDeadline().toLocalDate() %></small>
                                <% } else { %>
                                <i class="bi bi-infinity d-block fs-4 text-success"></i>
                                <small>Tanpa batas</small>
                                <% } %>
                            </div>
                        </div>
                        <% if (quiz.getDeadline() != null && !quiz.isExpired()) { %>
                        <div class="alert alert-warning py-2 mb-3 text-center">
                            <i class="bi bi-exclamation-triangle me-1"></i>
                            Deadline: <%= quiz.getFormattedDeadline() %>
                        </div>
                        <% } %>
                        <% if (hasSubmitted) { %>
                        <div class="alert alert-success py-2 mb-3 text-center">
                            <strong>Nilai Anda: <%= String.format("%.0f", sub.getScore()) %></strong>
                        </div>
                        <a href="../ExamServlet?action=result&submissionId=<%= sub.getId() %>"
                           class="btn btn-outline-primary w-100">
                            <i class="bi bi-eye me-1"></i>Lihat Hasil
                        </a>
                        <% } else { %>
                        <a href="../ExamServlet?action=start&quizId=<%= quiz.getId() %>"
                           class="btn btn-primary w-100"
                           onclick="return confirm('Mulai mengerjakan quiz ini? Pastikan Anda memiliki waktu yang cukup.')">
                            <i class="bi bi-play-fill me-1"></i>Mulai Quiz
                        </a>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="bi bi-journal-x display-1 text-muted mb-3 d-block"></i>
                <h5 class="text-muted">Belum ada quiz tersedia</h5>
                <p class="text-muted">Quiz akan muncul di sini setelah admin mempublish.</p>
                <a href="../ExamServlet?action=dashboard" class="btn btn-primary">
                    <i class="bi bi-arrow-left me-1"></i>Kembali ke Dashboard
                </a>
            </div>
        </div>
        <% } %>
    </div>

    <footer class="bg-light py-3 mt-auto">
        <div class="container text-center">
            <span class="text-muted">&copy; 2024 Examora. All rights reserved.</span>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
