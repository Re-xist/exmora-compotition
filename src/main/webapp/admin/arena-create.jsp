<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Quiz" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Buat Arena - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <!-- Sidebar -->
    <%@ include file="sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Buat Arena Baru</h1>
                <p class="text-muted mb-0">Buat room competitive quiz real-time</p>
            </div>
            <div>
                <a href="../ArenaServlet?action=list" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>Kembali
                </a>
            </div>
        </div>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Create Form -->
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-arena-gradient text-white">
                        <h5 class="mb-0"><i class="bi bi-plus-circle me-2"></i>Form Pembuatan Arena</h5>
                    </div>
                    <div class="card-body">
                        <form action="../ArenaServlet?action=create" method="POST">
                            <!-- Quiz Selection -->
                            <div class="mb-4">
                                <label for="quizId" class="form-label">Pilih Quiz <span class="text-danger">*</span></label>
                                <select class="form-select" id="quizId" name="quizId" required>
                                    <option value="">-- Pilih Quiz --</option>
                                    <% if (quizzes != null) {
                                        for (Quiz quiz : quizzes) { %>
                                    <option value="<%= quiz.getId() %>">
                                        <%= quiz.getTitle() %> (<%= quiz.getQuestionCount() %> soal)
                                    </option>
                                    <% }
                                    } %>
                                </select>
                                <div class="form-text">Pilih quiz yang akan digunakan untuk arena</div>
                            </div>

                            <!-- Question Time -->
                            <div class="mb-4">
                                <label for="questionTime" class="form-label">Waktu Per Soal (detik)</label>
                                <div class="input-group">
                                    <input type="number" class="form-control" id="questionTime" name="questionTime"
                                           value="30" min="10" max="120" required>
                                    <span class="input-group-text">detik</span>
                                </div>
                                <div class="form-text">Waktu yang diberikan untuk menjawab setiap soal (10-120 detik)</div>
                            </div>

                            <!-- Info Card -->
                            <div class="alert alert-info">
                                <h6 class="alert-heading"><i class="bi bi-info-circle me-2"></i>Informasi</h6>
                                <ul class="mb-0">
                                    <li>Kode arena akan digenerate otomatis (format: AR-XXXXX)</li>
                                    <li>Peserta dapat bergabung menggunakan kode tersebut</li>
                                    <li>Scoring berbasis kecepatan + kebenaran</li>
                                    <li>Nilai maksimal per soal: 100 poin</li>
                                </ul>
                            </div>

                            <!-- Submit Button -->
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="../ArenaServlet?action=list" class="btn btn-outline-secondary">
                                    <i class="bi bi-x-lg me-2"></i>Batal
                                </a>
                                <button type="submit" class="btn btn-arena">
                                    <i class="bi bi-plus-circle me-2"></i>Buat Arena
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Scoring Info -->
                <div class="card mt-4">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-calculator me-2"></i>Sistem Scoring</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>Formula:</h6>
                                <pre class="bg-light p-3 rounded">Skor = 100 x (sisa_waktu / total_waktu)
Jawaban salah = 0 poin
Minimum skor benar = 10 poin</pre>
                            </div>
                            <div class="col-md-6">
                                <h6>Contoh:</h6>
                                <ul>
                                    <li>Waktu 30 detik, jawab benar di detik ke-10: <strong>67 pts</strong></li>
                                    <li>Waktu 30 detik, jawab benar di detik ke-25: <strong>17 pts</strong></li>
                                    <li>Jawaban salah: <strong>0 pts</strong></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
