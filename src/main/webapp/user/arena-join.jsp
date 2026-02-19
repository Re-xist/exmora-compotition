<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    if (currentUser.isAdmin()) {
        response.sendRedirect("../ArenaServlet?action=list");
        return;
    }

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gabung Arena - Examora</title>
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
                        <a class="nav-link" href="../ExamServlet?action=list">
                            <i class="bi bi-journal-text me-1"></i>Quiz Tersedia
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="../ArenaServlet?action=join">
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
                    <a href="../LogoutServlet" class="btn btn-outline-light btn-sm">
                        <i class="bi bi-box-arrow-left me-1"></i>Logout
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <!-- Header -->
                <div class="text-center mb-4">
                    <div class="bg-arena-gradient text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                         style="width: 100px; height: 100px;">
                        <i class="bi bi-trophy" style="font-size: 3rem;"></i>
                    </div>
                    <h2>Examora Arena</h2>
                    <p class="text-muted">Competitive Quiz Real-Time</p>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <!-- Join Form -->
                <div class="card shadow-lg border-0">
                    <div class="card-header bg-arena-gradient text-white text-center py-4">
                        <h4 class="mb-0"><i class="bi bi-box-arrow-in-right me-2"></i>Gabung Arena</h4>
                    </div>
                    <div class="card-body p-4">
                        <form action="../ArenaServlet?action=join" method="POST">
                            <div class="mb-4">
                                <label for="code" class="form-label">Kode Arena</label>
                                <input type="text" class="form-control form-control-lg text-center"
                                       id="code" name="code" placeholder="AR-XXXXX"
                                       maxlength="8" required
                                       style="text-transform: uppercase; letter-spacing: 3px; font-family: monospace;">
                                <div class="form-text text-center">Masukkan kode yang diberikan oleh host</div>
                            </div>

                            <div class="d-grid">
                                <button type="submit" class="btn btn-arena btn-lg">
                                    <i class="bi bi-lightning-fill me-2"></i>Gabung Sekarang
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Info -->
                <div class="card mt-4">
                    <div class="card-body">
                        <h6 class="mb-3"><i class="bi bi-info-circle me-2"></i>Cara Bermain</h6>
                        <ol class="mb-0">
                            <li>Masukkan kode arena dari host</li>
                            <li>Tunggu hingga host memulai arena</li>
                            <li>Jawab soal secepat mungkin</li>
                            <li>Semakin cepat benar, semakin tinggi skornya!</li>
                        </ol>
                    </div>
                </div>

                <!-- Scoring Info -->
                <div class="card mt-3">
                    <div class="card-body">
                        <h6 class="mb-3"><i class="bi bi-calculator me-2"></i>Sistem Scoring</h6>
                        <div class="row text-center">
                            <div class="col-4">
                                <div class="bg-light rounded p-2">
                                    <div class="text-arena fw-bold">100</div>
                                    <small class="text-muted">Max Poin</small>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="bg-light rounded p-2">
                                    <div class="text-success fw-bold">Speed</div>
                                    <small class="text-muted">Bonus</small>
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="bg-light rounded p-2">
                                    <div class="text-danger fw-bold">0</div>
                                    <small class="text-muted">Jika Salah</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-light py-3 mt-auto">
        <div class="container text-center">
            <span class="text-muted">&copy; 2026 Examora. All rights reserved.</span>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto uppercase for code input
        document.getElementById('code').addEventListener('input', function(e) {
            e.target.value = e.target.value.toUpperCase();
        });
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
