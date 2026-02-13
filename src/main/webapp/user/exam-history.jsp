<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Submission" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    List<Submission> submissions = (List<Submission>) request.getAttribute("submissions");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Riwayat Ujian - Examora</title>
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
                        <a class="nav-link active" href="../ExamServlet?action=history">
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
        <h2 class="mb-4"><i class="bi bi-clock-history me-2"></i>Riwayat Ujian</h2>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (submissions != null && !submissions.isEmpty()) { %>
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Quiz</th>
                                <th>Nilai</th>
                                <th>Benar</th>
                                <th>Waktu</th>
                                <th>Tanggal</th>
                                <th>Status</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int no = 1;
                               for (Submission sub : submissions) {
                                   String scoreClass = sub.getScore() >= 75 ? "text-success" :
                                                      sub.getScore() >= 60 ? "text-warning" : "text-danger";
                            %>
                            <tr>
                                <td><%= no++ %></td>
                                <td><strong><%= sub.getQuizTitle() %></strong></td>
                                <td>
                                    <span class="<%= scoreClass %> fw-bold">
                                        <%= String.format("%.0f", sub.getScore()) %>
                                    </span>
                                </td>
                                <td><%= sub.getCorrectAnswers() %>/<%= sub.getTotalQuestions() %></td>
                                <td><%= sub.getFormattedTimeSpent() %></td>
                                <td><%= sub.getSubmittedAt() != null ? sub.getSubmittedAt().toLocalDate() : "-" %></td>
                                <td>
                                    <% if ("completed".equals(sub.getStatus())) { %>
                                    <span class="badge bg-success">Selesai</span>
                                    <% } else if ("timeout".equals(sub.getStatus())) { %>
                                    <span class="badge bg-warning">Waktu Habis</span>
                                    <% } else { %>
                                    <span class="badge bg-secondary">In Progress</span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="../ExamServlet?action=result&submissionId=<%= sub.getId() %>"
                                       class="btn btn-sm btn-outline-primary">
                                        <i class="bi bi-eye me-1"></i>Detail
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Summary Statistics -->
        <div class="row mt-4">
            <div class="col-md-4">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-primary"><%= submissions.size() %></h3>
                        <p class="text-muted mb-0">Total Quiz Dikerjakan</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-success">
                            <%= String.format("%.0f", submissions.stream()
                                .mapToDouble(Submission::getScore)
                                .average()
                                .orElse(0)) %>
                        </h3>
                        <p class="text-muted mb-0">Rata-rata Nilai</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center">
                    <div class="card-body">
                        <h3 class="text-info">
                            <%= String.format("%.0f", submissions.stream()
                                .mapToDouble(Submission::getScore)
                                .max()
                                .orElse(0)) %>
                        </h3>
                        <p class="text-muted mb-0">Nilai Tertinggi</p>
                    </div>
                </div>
            </div>
        </div>
        <% } else { %>
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="bi bi-clock-history display-1 text-muted mb-3 d-block"></i>
                <h5 class="text-muted">Belum ada riwayat ujian</h5>
                <p class="text-muted">Mulai mengerjakan quiz untuk melihat riwayat di sini.</p>
                <a href="../ExamServlet?action=list" class="btn btn-primary">
                    <i class="bi bi-journal-text me-1"></i>Lihat Quiz Tersedia
                </a>
            </div>
        </div>
        <% } %>
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
