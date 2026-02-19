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
    if (currentUser.isAdmin()) {
        response.sendRedirect("../AdminServlet?action=dashboard");
        return;
    }
    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    Map<Integer, Submission> userSubmissions = (Map<Integer, Submission>) request.getAttribute("userSubmissions");
    List<Submission> recentSubmissions = (List<Submission>) request.getAttribute("recentSubmissions");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand fw-bold" href="dashboard.jsp">
                <i class="bi bi-journal-check me-2"></i>Examora
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="../ExamServlet?action=dashboard">
                            <i class="bi bi-house me-1"></i>Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../ExamServlet?action=list">
                            <i class="bi bi-journal-text me-1"></i>Quiz Tersedia
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../ArenaServlet?action=join">
                            <i class="bi bi-trophy me-1"></i>Arena
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../AttendanceServlet?action=view">
                            <i class="bi bi-check2-square me-1"></i>Absensi
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../ExamServlet?action=history">
                            <i class="bi bi-clock-history me-1"></i>Riwayat
                        </a>
                    </li>
                    <% if (currentUser.getGdriveLink() != null && !currentUser.getGdriveLink().isEmpty()) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#gdriveModal">
                            <i class="bi bi-google me-1"></i>Google Drive
                        </a>
                    </li>
                    <% } %>
                </ul>
                <div class="d-flex align-items-center">
                    <a href="../SettingsServlet" class="text-white text-decoration-none me-3">
                        <i class="bi bi-person-circle me-1"></i><%= currentUser.getName() %>
                    </a>
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
        <% if (success != null) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i><%= success %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Welcome Banner -->
        <div class="card bg-primary text-white mb-4">
            <div class="card-body py-4">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h2 class="mb-2">Selamat Datang, <%= currentUser.getName() %>!</h2>
                        <p class="mb-0 opacity-75">Siap untuk memulai ujian? Pilih quiz yang tersedia di bawah ini.</p>
                    </div>
                    <div class="col-md-4 text-end">
                        <i class="bi bi-mortarboard-fill" style="font-size: 4rem; opacity: 0.3;"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Available Quizzes -->
        <h4 class="mb-3"><i class="bi bi-journal-text me-2"></i>Quiz Tersedia</h4>

        <% if (quizzes != null && !quizzes.isEmpty()) { %>
        <div class="row g-4 mb-4">
            <% for (Quiz quiz : quizzes) {
                Submission sub = userSubmissions != null ? userSubmissions.get(quiz.getId()) : null;
                boolean hasSubmitted = sub != null && sub.isCompleted();
            %>
            <div class="col-md-6 col-lg-4">
                <div class="card h-100 quiz-card">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="card-title mb-0"><%= quiz.getTitle() %></h5>
                            <% if (hasSubmitted) { %>
                            <span class="badge bg-success"><i class="bi bi-check-circle me-1"></i>Selesai</span>
                            <% } else { %>
                            <span class="badge bg-primary"><i class="bi bi-play-circle me-1"></i>Tersedia</span>
                            <% } %>
                        </div>
                        <p class="card-text text-muted small mb-3">
                            <%= quiz.getDescription() != null && quiz.getDescription().length() > 80 ?
                                quiz.getDescription().substring(0, 80) + "..." : (quiz.getDescription() != null ? quiz.getDescription() : "Tidak ada deskripsi") %>
                        </p>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="text-muted small">
                                <i class="bi bi-clock me-1"></i><%= quiz.getDuration() %> menit
                            </span>
                            <span class="text-muted small">
                                <i class="bi bi-question-circle me-1"></i><%= quiz.getQuestionCount() %> soal
                            </span>
                        </div>
                        <% if (hasSubmitted) { %>
                        <div class="d-flex gap-2">
                            <a href="../ExamServlet?action=result&submissionId=<%= sub.getId() %>"
                               class="btn btn-outline-primary w-100">
                                <i class="bi bi-eye me-1"></i>Lihat Hasil
                            </a>
                        </div>
                        <div class="text-center mt-2">
                            <strong>Nilai: <%= String.format("%.0f", sub.getScore()) %></strong>
                        </div>
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
            </div>
        </div>
        <% } %>
    </div>

    <!-- Footer -->
    <footer class="bg-light py-3 mt-auto">
        <div class="container text-center">
            <span class="text-muted">&copy; 2026 Examora. All rights reserved.</span>
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

    <!-- Google Drive Modal -->
    <% if (currentUser.getGdriveLink() != null && !currentUser.getGdriveLink().isEmpty()) { %>
    <div class="modal fade" id="gdriveModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-danger text-white border-0">
                    <h5 class="modal-title">
                        <i class="bi bi-google me-2"></i>Google Drive - Pengumpulan Tugas
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <div class="mb-4">
                        <div class="bg-danger bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center"
                             style="width: 80px; height: 80px;">
                            <i class="bi bi-folder2-open text-danger" style="font-size: 2.5rem;"></i>
                        </div>
                    </div>
                    <h5 class="mb-3">Folder Pengumpulan Tugas & Feedback</h5>
                    <p class="text-muted mb-4">
                        Ini adalah folder Google Drive pribadi Anda untuk:
                    </p>
                    <div class="text-start bg-light p-3 rounded mb-4">
                        <ul class="mb-0">
                            <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i>Mengumpulkan tugas dan assignment</li>
                            <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i>Menerima feedback dari mentor</li>
                            <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i>Melihat hasil review dan nilai</li>
                            <li><i class="bi bi-check-circle text-success me-2"></i>Dokumen pembelajaran lainnya</li>
                        </ul>
                    </div>
                    <div class="alert alert-info text-start mb-0">
                        <i class="bi bi-info-circle me-2"></i>
                        <strong>Catatan:</strong> Pastikan Anda sudah login dengan akun Google yang terdaftar untuk mengakses folder ini.
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-outline-secondary px-4" data-bs-dismiss="modal">
                        <i class="bi bi-x-lg me-1"></i>Tutup
                    </button>
                    <a href="<%= currentUser.getGdriveLink() %>" target="_blank" class="btn btn-danger px-4">
                        <i class="bi bi-box-arrow-up-right me-1"></i>Buka Google Drive
                    </a>
                </div>
            </div>
        </div>
    </div>
    <% } %>
</body>
</html>
