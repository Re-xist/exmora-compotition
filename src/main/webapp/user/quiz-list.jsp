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
                        <a class="nav-link" href="../ArenaServlet?action=join">
                            <i class="bi bi-trophy me-1"></i>Arena
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
                        <button type="button" class="btn btn-primary w-100"
                                onclick="showStartQuizModal(<%= quiz.getId() %>, '<%= quiz.getTitle().replace("'", "\\'") %>', <%= quiz.getDuration() %>, <%= quiz.getQuestionCount() %>)">
                            <i class="bi bi-play-fill me-1"></i>Mulai Quiz
                        </button>
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

    <!-- Start Quiz Confirmation Modal -->
    <div class="modal fade" id="startQuizModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-primary text-white border-0">
                    <h5 class="modal-title">
                        <i class="bi bi-play-circle me-2"></i>Konfirmasi Mulai Quiz
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <div class="mb-4">
                        <div class="bg-primary bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center"
                             style="width: 80px; height: 80px;">
                            <i class="bi bi-journal-check text-primary" style="font-size: 2.5rem;"></i>
                        </div>
                    </div>
                    <h5 class="mb-3" id="modalQuizTitle">Nama Quiz</h5>
                    <div class="row justify-content-center mb-4">
                        <div class="col-auto">
                            <div class="text-center px-3">
                                <i class="bi bi-clock text-primary fs-4"></i>
                                <div class="fw-bold" id="modalQuizDuration">30</div>
                                <small class="text-muted">menit</small>
                            </div>
                        </div>
                        <div class="col-auto">
                            <div class="text-center px-3 border-start">
                                <i class="bi bi-question-circle text-primary fs-4"></i>
                                <div class="fw-bold" id="modalQuizQuestions">10</div>
                                <small class="text-muted">soal</small>
                            </div>
                        </div>
                    </div>
                    <div class="alert alert-warning text-start mb-0">
                        <h6 class="alert-heading mb-2">
                            <i class="bi bi-exclamation-triangle me-2"></i>Perhatian!
                        </h6>
                        <ul class="mb-0 small">
                            <li>Pastikan Anda memiliki waktu yang cukup</li>
                            <li>Quiz tidak dapat dijeda setelah dimulai</li>
                            <li>Pastikan koneksi internet stabil</li>
                            <li>Jangan refresh atau tutup halaman saat mengerjakan</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">
                        <i class="bi bi-x-lg me-1"></i>Batal
                    </button>
                    <a href="#" id="startQuizBtn" class="btn btn-primary px-4">
                        <i class="bi bi-play-fill me-1"></i>Mulai Sekarang
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function showStartQuizModal(quizId, title, duration, questions) {
            document.getElementById('modalQuizTitle').textContent = title;
            document.getElementById('modalQuizDuration').textContent = duration;
            document.getElementById('modalQuizQuestions').textContent = questions;
            document.getElementById('startQuizBtn').href = '../ExamServlet?action=start&quizId=' + quizId;

            var modal = new bootstrap.Modal(document.getElementById('startQuizModal'));
            modal.show();
        }
    </script>
</body>
</html>
