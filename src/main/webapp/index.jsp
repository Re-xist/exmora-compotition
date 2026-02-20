<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    <meta name="description" content="Platform Ujian Online dengan Fitur Lengkap - Quiz, Arena, Statistik, dan Integrasi Google Drive">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="assets/img/favicon.svg">
    <style>
        .feature-icon {
            width: 70px;
            height: 70px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
        }
        .hero-section {
            background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
        }
        .arena-gradient {
            background: linear-gradient(135deg, #fd7e14 0%, #dc3545 100%);
        }
    </style>
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
                        <a class="nav-link" href="#arena">Arena</a>
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
                        Platform ujian online lengkap dengan sistem quiz interaktif,
                        Arena kompetisi real-time, statistik performa, dan integrasi Google Drive
                        untuk pengumpulan tugas dan feedback mentor.
                    </p>
                    <div class="row g-3 mb-4">
                        <div class="col-auto">
                            <div class="d-flex align-items-center text-white">
                                <i class="bi bi-journal-text fs-4 me-2"></i>
                                <span>Quiz Online</span>
                            </div>
                        </div>
                        <div class="col-auto">
                            <div class="d-flex align-items-center text-white">
                                <i class="bi bi-trophy fs-4 me-2"></i>
                                <span>Arena Live</span>
                            </div>
                        </div>
                        <div class="col-auto">
                            <div class="d-flex align-items-center text-white">
                                <i class="bi bi-collection fs-4 me-2"></i>
                                <span>Bank Soal</span>
                            </div>
                        </div>
                        <div class="col-auto">
                            <div class="d-flex align-items-center text-white">
                                <i class="bi bi-award fs-4 me-2"></i>
                                <span>Achievements</span>
                            </div>
                        </div>
                        <div class="col-auto">
                            <div class="d-flex align-items-center text-white">
                                <i class="bi bi-envelope fs-4 me-2"></i>
                                <span>Notifikasi</span>
                            </div>
                        </div>
                    </div>
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
                <h2 class="display-6 fw-bold">Fitur Lengkap</h2>
                <p class="text-muted">Semua yang Anda butuhkan untuk sistem ujian online</p>
            </div>
            <div class="row g-4">
                <!-- Quiz Management -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon bg-primary text-white rounded-circle mb-3">
                                <i class="bi bi-journal-text"></i>
                            </div>
                            <h5 class="card-title">Manajemen Quiz</h5>
                            <p class="card-text text-muted">
                                Buat dan kelola quiz dengan berbagai jenis soal, atur durasi,
                                deadline, dan publish ke peserta dengan mudah.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Multiple choice questions</li>
                                <li><i class="bi bi-check text-success me-1"></i>Timer & auto-submit</li>
                                <li><i class="bi bi-check text-success me-1"></i>Deadline per quiz</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Arena Mode -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon arena-gradient text-white rounded-circle mb-3">
                                <i class="bi bi-trophy"></i>
                            </div>
                            <h5 class="card-title">Arena Live</h5>
                            <p class="card-text text-muted">
                                Mode kompetisi real-time! Host membuat room, peserta bergabung
                                dengan kode, dan bermain bersama-sama.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Real-time leaderboard</li>
                                <li><i class="bi bi-check text-success me-1"></i>Kode room unik</li>
                                <li><i class="bi bi-check text-success me-1"></i>Live scoring</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Google Drive Integration -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon bg-danger text-white rounded-circle mb-3">
                                <i class="bi bi-google"></i>
                            </div>
                            <h5 class="card-title">Integrasi Google Drive</h5>
                            <p class="card-text text-muted">
                                Setiap peserta memiliki link Google Drive pribadi untuk
                                mengumpulkan tugas dan menerima feedback dari mentor.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Folder personal</li>
                                <li><i class="bi bi-check text-success me-1"></i>Pengumpulan tugas</li>
                                <li><i class="bi bi-check text-success me-1"></i>Feedback mentor</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Statistics -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon bg-success text-white rounded-circle mb-3">
                                <i class="bi bi-graph-up"></i>
                            </div>
                            <h5 class="card-title">Statistik & Analitik</h5>
                            <p class="card-text text-muted">
                                Pantau performa peserta dengan visualisasi data lengkap,
                                distribusi nilai, dan analisis per soal.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Distribusi nilai</li>
                                <li><i class="bi bi-check text-success me-1"></i>Pass rate analysis</li>
                                <li><i class="bi bi-check text-success me-1"></i>Export ke PDF</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- User Management -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon bg-info text-white rounded-circle mb-3">
                                <i class="bi bi-people"></i>
                            </div>
                            <h5 class="card-title">Manajemen User</h5>
                            <p class="card-text text-muted">
                                Kelola peserta dengan sistem tag/kelompok, import CSV
                                untuk pendaftaran massal, dan pengaturan role.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Import CSV bulk</li>
                                <li><i class="bi bi-check text-success me-1"></i>Tag & grouping</li>
                                <li><i class="bi bi-check text-success me-1"></i>Multi-role system</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Exam History -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon bg-warning text-white rounded-circle mb-3">
                                <i class="bi bi-clock-history"></i>
                            </div>
                            <h5 class="card-title">Riwayat Ujian</h5>
                            <p class="card-text text-muted">
                                Peserta dapat melihat semua riwayat pengerjaan quiz,
                                nilai yang diperoleh, dan review jawaban.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>History lengkap</li>
                                <li><i class="bi bi-check text-success me-1"></i>Review jawaban</li>
                                <li><i class="bi bi-check text-success me-1"></i>Detail skor</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Auto Grading -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon bg-secondary text-white rounded-circle mb-3">
                                <i class="bi bi-clipboard-check"></i>
                            </div>
                            <h5 class="card-title">Auto Grading</h5>
                            <p class="card-text text-muted">
                                Koreksi otomatis dengan perhitungan skor real-time,
                                hasil akurat, dan feedback instan untuk peserta.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Scoring instan</li>
                                <li><i class="bi bi-check text-success me-1"></i>Hasil akurat</li>
                                <li><i class="bi bi-check text-success me-1"></i>Feedback langsung</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Secure System -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon bg-dark text-white rounded-circle mb-3">
                                <i class="bi bi-shield-lock"></i>
                            </div>
                            <h5 class="card-title">Secure Assessment</h5>
                            <p class="card-text text-muted">
                                Sistem keamanan terintegrasi dengan session validation,
                                prevent cheating, dan secure data handling.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Session validation</li>
                                <li><i class="bi bi-check text-success me-1"></i>Prevent cheating</li>
                                <li><i class="bi bi-check text-success me-1"></i>Secure database</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Attendance System -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon text-white rounded-circle mb-3" style="background-color: #20c997;">
                                <i class="bi bi-check2-square"></i>
                            </div>
                            <h5 class="card-title">Sistem Absensi</h5>
                            <p class="card-text text-muted">
                                Kelola kehadiran peserta dengan kode unik, jadwal sesi,
                                dan export rekap kehadiran ke PDF/CSV.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Kode absensi unik</li>
                                <li><i class="bi bi-check text-success me-1"></i>Export PDF/CSV</li>
                                <li><i class="bi bi-check text-success me-1"></i>Target per tag</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Question Bank -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon text-white rounded-circle mb-3" style="background-color: #6f42c1;">
                                <i class="bi bi-collection"></i>
                            </div>
                            <h5 class="card-title">Bank Soal</h5>
                            <p class="card-text text-muted">
                                Simpan dan kelola pool soal untuk digunakan ulang di berbagai quiz
                                dengan kategorisasi yang mudah.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Reuse soal</li>
                                <li><i class="bi bi-check text-success me-1"></i>Kategori soal</li>
                                <li><i class="bi bi-check text-success me-1"></i>Pilih saat buat quiz</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Achievements -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon text-white rounded-circle mb-3" style="background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);">
                                <i class="bi bi-award"></i>
                            </div>
                            <h5 class="card-title">Achievements</h5>
                            <p class="card-text text-muted">
                                Sistem badge dan gamification untuk meningkatkan engagement
                                peserta dengan reward berbasis performa.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Badge & points</li>
                                <li><i class="bi bi-check text-success me-1"></i>Perfect score reward</li>
                                <li><i class="bi bi-check text-success me-1"></i>Leaderboard</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Notifications -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon text-white rounded-circle mb-3" style="background-color: #0dcaf0;">
                                <i class="bi bi-envelope"></i>
                            </div>
                            <h5 class="card-title">Notifikasi Email</h5>
                            <p class="card-text text-muted">
                                Template email yang dapat dikustomisasi untuk notifikasi quiz baru,
                                deadline, dan hasil quiz.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Email templates</li>
                                <li><i class="bi bi-check text-success me-1"></i>Deadline reminder</li>
                                <li><i class="bi bi-check text-success me-1"></i>Result notification</li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- Audit Log -->
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body p-4">
                            <div class="feature-icon text-white rounded-circle mb-3" style="background-color: #495057;">
                                <i class="bi bi-clipboard-data"></i>
                            </div>
                            <h5 class="card-title">Audit Log</h5>
                            <p class="card-text text-muted">
                                Tracking semua aktivitas admin dengan detail lengkap
                                termasuk IP address dan timestamp.
                            </p>
                            <ul class="list-unstyled text-muted small mb-0">
                                <li><i class="bi bi-check text-success me-1"></i>Login/logout tracking</li>
                                <li><i class="bi bi-check text-success me-1"></i>CRUD operations</li>
                                <li><i class="bi bi-check text-success me-1"></i>Filter & search</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Arena Section -->
    <section id="arena" class="py-5 arena-gradient">
        <div class="container py-5">
            <div class="row align-items-center">
                <div class="col-lg-6 text-white">
                    <span class="badge bg-light text-dark mb-3">Fitur Unggulan</span>
                    <h2 class="display-5 fw-bold mb-4">
                        <i class="bi bi-trophy me-2"></i>Arena Mode
                    </h2>
                    <p class="lead mb-4">
                        Rasakan sensasi kompetisi quiz secara real-time!
                        Arena Mode mengubah ujian menjadi pengalaman yang menyenangkan dan interaktif.
                    </p>
                    <div class="row g-3 mb-4">
                        <div class="col-6">
                            <div class="bg-white bg-opacity-10 rounded p-3">
                                <i class="bi bi-people fs-2 d-block mb-2"></i>
                                <strong>Multiplayer</strong>
                                <p class="small mb-0">Banyak peserta sekaligus</p>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="bg-white bg-opacity-10 rounded p-3">
                                <i class="bi bi-bar-chart fs-2 d-block mb-2"></i>
                                <strong>Leaderboard</strong>
                                <p class="small mb-0">Real-time scoring</p>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="bg-white bg-opacity-10 rounded p-3">
                                <i class="bi bi-key fs-2 d-block mb-2"></i>
                                <strong>Kode Room</strong>
                                <p class="small mb-0">Gabung dengan kode unik</p>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="bg-white bg-opacity-10 rounded p-3">
                                <i class="bi bi-stopwatch fs-2 d-block mb-2"></i>
                                <strong>Timer</strong>
                                <p class="small mb-0">Waktu per soal</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="card border-0 shadow-lg">
                        <div class="card-header bg-dark text-white">
                            <h5 class="mb-0"><i class="bi bi-trophy text-warning me-2"></i>Cara Kerja Arena</h5>
                        </div>
                        <div class="card-body">
                            <div class="d-flex mb-3">
                                <div class="rounded-circle bg-warning text-dark d-flex align-items-center justify-content-center me-3"
                                     style="width: 40px; height: 40px; font-weight: bold;">1</div>
                                <div>
                                    <h6 class="mb-1">Host Membuat Arena</h6>
                                    <p class="text-muted small mb-0">Admin membuat room arena dan mendapatkan kode unik</p>
                                </div>
                            </div>
                            <div class="d-flex mb-3">
                                <div class="rounded-circle bg-warning text-dark d-flex align-items-center justify-content-center me-3"
                                     style="width: 40px; height: 40px; font-weight: bold;">2</div>
                                <div>
                                    <h6 class="mb-1">Peserta Bergabung</h6>
                                    <p class="text-muted small mb-0">Masukkan kode arena untuk bergabung ke lobby</p>
                                </div>
                            </div>
                            <div class="d-flex mb-3">
                                <div class="rounded-circle bg-warning text-dark d-flex align-items-center justify-content-center me-3"
                                     style="width: 40px; height: 40px; font-weight: bold;">3</div>
                                <div>
                                    <h6 class="mb-1">Kompetisi Dimulai</h6>
                                    <p class="text-muted small mb-0">Jawab soal secepat mungkin untuk poin tinggi</p>
                                </div>
                            </div>
                            <div class="d-flex">
                                <div class="rounded-circle bg-warning text-dark d-flex align-items-center justify-content-center me-3"
                                     style="width: 40px; height: 40px; font-weight: bold;">4</div>
                                <div>
                                    <h6 class="mb-1">Lihat Hasil</h6>
                                    <p class="text-muted small mb-0">Leaderboard real-time dan hasil akhir</p>
                                </div>
                            </div>
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
                        Examora berfungsi sebagai <strong>platform asesmen teori</strong> dimana peserta
                        mengerjakan soal quiz untuk mendapatkan nilai dari pengyelenggara.
                    </p>
                    <div class="card bg-light border-0 mb-4">
                        <div class="card-body">
                            <code class="text-primary">
                                Materi &rarr; <strong>Examora (Quiz Teori + Nilai)</strong> &rarr; Lab/CTF &rarr; Final Assessment &rarr; Certification
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
                                Masuk ke akun Anda untuk mulai mengerjakan quiz,
                                bergabung ke Arena, atau mengelola sistem.
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
                        Platform Ujian Online dengan fitur lengkap: Quiz, Arena, Statistik, dan Google Drive
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
                        &copy; 2026 Examora. All rights reserved.
                    </p>
                </div>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
