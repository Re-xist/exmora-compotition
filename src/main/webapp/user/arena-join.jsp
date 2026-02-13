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
            <a class="navbar-brand fw-bold" href="dashboard.jsp">
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
                        <a class="nav-link" href="../ExamServlet?action=history">
                            <i class="bi bi-clock-history me-1"></i>Riwayat
                        </a>
                    </li>
                </ul>
                <div class="d-flex align-items-center">
                    <a href="../SettingsServlet" class="text-white text-decoration-none me-3">
                        <i class="bi bi-person-circle me-1"></i><%= currentUser.getName() %>
                    </a>
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
            <span class="text-muted">&copy; 2024 Examora. All rights reserved.</span>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto uppercase for code input
        document.getElementById('code').addEventListener('input', function(e) {
            e.target.value = e.target.value.toUpperCase();
        });
    </script>
</body>
</html>
