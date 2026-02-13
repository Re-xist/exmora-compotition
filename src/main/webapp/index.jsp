<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    String redirectUrl = "";
    if (user != null) {
        redirectUrl = user.isAdmin() ? "admin/dashboard.jsp" : "user/dashboard.jsp";
        response.sendRedirect(redirectUrl);
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examora - Secure Assessment Platform</title>
    <meta name="description" content="Official Secure Assessment Platform by IDS Cyber Security Academy">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet">
</head>
<body class="landing-page">
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary fixed-top">
        <div class="container">
            <a class="navbar-brand fw-bold" href="#">
                <i class="bi bi-journal-check me-2"></i>Examora
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="#features">Fitur</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#about">Tentang</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-light ms-2" href="LoginServlet">
                            <i class="bi bi-box-arrow-in-right me-1"></i>Masuk
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-outline-light ms-2" href="RegisterServlet">
                            <i class="bi bi-person-plus me-1"></i>Daftar
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="container">
            <div class="row align-items-center min-vh-100">
                <div class="col-lg-6">
                    <span class="badge bg-warning text-dark mb-3">IDS Cyber Security Academy</span>
                    <h1 class="display-4 fw-bold text-white mb-4">
                        Examora
                        <span class="d-block text-warning">Secure Assessment Platform</span>
                    </h1>
                    <p class="lead text-white-50 mb-4">
                        Platform ujian dan sistem evaluasi resmi untuk mengukur, memvalidasi,
                        dan mendokumentasikan kompetensi peserta secara terstruktur.
                    </p>
                    <p class="text-white-50 mb-4">
                        Examora dirancang sebagai <strong>Secure Online Assessment System</strong>
                        yang memastikan setiap peserta memahami konsep keamanan siber sebelum
                        melanjutkan ke tahap praktik dan eksploitasi di lab.
                    </p>
                    <div class="d-flex gap-3">
                        <a href="RegisterServlet" class="btn btn-warning btn-lg px-4">
                            <i class="bi bi-rocket-takeoff me-2"></i>Mulai Sekarang
                        </a>
                        <a href="#features" class="btn btn-outline-light btn-lg px-4">
                            Pelajari Lebih Lanjut
                        </a>
                    </div>
                </div>
                <div class="col-lg-6 text-center">
                    <div class="hero-illustration">
                        <i class="bi bi-shield-lock" style="font-size: 12rem; color: rgba(255,255,255,0.2);"></i>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="py-5 bg-light">
        <div class="container py-5">
            <div class="text-center mb-5">
                <h2 class="display-6 fw-bold">Fitur Unggulan</h2>
                <p class="text-muted">Secure Assessment System dengan fitur lengkap</p>
            </div>
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="feature-icon bg-primary text-white rounded-circle mb-3 mx-auto">
                                <i class="bi bi-bullseye"></i>
                            </div>
                            <h5 class="card-title">Validasi Kompetensi</h5>
                            <p class="card-text text-muted">
                                Memastikan peserta memahami konsep keamanan siber, OWASP Top 10,
                                dan metodologi penetration testing.
                            </p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="feature-icon bg-success text-white rounded-circle mb-3 mx-auto">
                                <i class="bi bi-shield-check"></i>
                            </div>
                            <h5 class="card-title">Secure Assessment</h5>
                            <p class="card-text text-muted">
                                Timed exam system, session validation, single submit enforcement,
                                dan secure database handling.
                            </p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="feature-icon bg-info text-white rounded-circle mb-3 mx-auto">
                                <i class="bi bi-stopwatch"></i>
                            </div>
                            <h5 class="card-title">Timer & Deadline</h5>
                            <p class="card-text text-muted">
                                Timer countdown dengan auto-submit dan deadline quiz
                                dengan format waktu WIB (Jakarta).
                            </p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="feature-icon bg-warning text-white rounded-circle mb-3 mx-auto">
                                <i class="bi bi-graph-up"></i>
                            </div>
                            <h5 class="card-title">Monitoring Progres</h5>
                            <p class="card-text text-muted">
                                Melihat performa peserta, menganalisis kelemahan materi,
                                dan membuat laporan akademik terpusat.
                            </p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="feature-icon bg-danger text-white rounded-circle mb-3 mx-auto">
                                <i class="bi bi-clipboard-check"></i>
                            </div>
                            <h5 class="card-title">Auto Grading</h5>
                            <p class="card-text text-muted">
                                Koreksi otomatis dengan perhitungan skor real-time dan
                                hasil yang akurat.
                            </p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center p-4">
                            <div class="feature-icon bg-secondary text-white rounded-circle mb-3 mx-auto">
                                <i class="bi bi-people"></i>
                            </div>
                            <h5 class="card-title">Multi-Role System</h5>
                            <p class="card-text text-muted">
                                Sistem role admin dan peserta dengan akses dan fitur yang berbeda.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- About Section -->
    <section id="about" class="py-5">
        <div class="container py-5">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <h2 class="display-6 fw-bold mb-4">Posisi dalam Ekosistem IDS</h2>
                    <p class="lead text-muted mb-4">
                        Examora berfungsi sebagai <strong>validation layer</strong> antara
                        teori dan praktik dalam struktur pembelajaran IDS.
                    </p>
                    <div class="card bg-light border-0 mb-4">
                        <div class="card-body">
                            <code class="text-primary">
                                Materi &rarr; <strong>Examora</strong> &rarr; Lab/CTF &rarr; Final Assessment &rarr; Certification
                            </code>
                        </div>
                    </div>
                    <h5 class="mb-3">Nilai Strategis:</h5>
                    <ul class="list-unstyled">
                        <li class="mb-3">
                            <i class="bi bi-check-circle-fill text-success me-2"></i>
                            Peserta tidak hanya menggunakan tools, tapi memahami logic serangan
                        </li>
                        <li class="mb-3">
                            <i class="bi bi-check-circle-fill text-success me-2"></i>
                            Proses evaluasi objektif dan transparan
                        </li>
                        <li class="mb-3">
                            <i class="bi bi-check-circle-fill text-success me-2"></i>
                            Standar kompetensi tetap terjaga
                        </li>
                        <li class="mb-3">
                            <i class="bi bi-check-circle-fill text-success me-2"></i>
                            Kualitas lulusan cyber security terjamin
                        </li>
                    </ul>
                </div>
                <div class="col-lg-6">
                    <div class="card border-0 shadow-lg">
                        <div class="card-body p-5">
                            <h4 class="mb-4">Mulai Sekarang</h4>
                            <p class="text-muted mb-4">
                                Masuk ke akun Anda untuk mulai mengerjakan quiz atau mengelola ujian.
                            </p>
                            <a href="LoginServlet" class="btn btn-primary w-100">
                                <i class="bi bi-box-arrow-in-right me-2"></i>Login Sekarang
                            </a>
                            <hr class="my-4">
                            <p class="text-center text-muted mb-0">
                                Belum punya akun? <a href="RegisterServlet">Daftar di sini</a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-dark text-white py-4">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <h5><i class="bi bi-journal-check me-2"></i>Examora</h5>
                    <p class="text-muted mb-1">
                        Official Secure Assessment Platform
                    </p>
                    <p class="text-muted mb-0">
                        <small>IDS Cyber Security Academy</small>
                    </p>
                </div>
                <div class="col-md-6 text-md-end">
                    <p class="mb-1">
                        <small>Developer: <a href="https://github.com/Re-xist" class="text-warning">Re-xist</a></small>
                    </p>
                    <p class="mb-0 text-muted">
                        &copy; 2024 Examora. All rights reserved.
                    </p>
                </div>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
