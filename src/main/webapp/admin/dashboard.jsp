<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    // Get statistics
    Integer totalUsers = (Integer) request.getAttribute("totalUsers");
    Integer totalAdmins = (Integer) request.getAttribute("totalAdmins");
    Integer totalQuizzes = (Integer) request.getAttribute("totalQuizzes");
    Integer totalSubmissions = (Integer) request.getAttribute("totalSubmissions");
    List<?> quizzes = (List<?>) request.getAttribute("quizzes");
    List<?> submissions = (List<?>) request.getAttribute("submissions");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <!-- Sidebar -->
    <nav class="sidebar">
        <a href="../index.jsp" class="sidebar-brand">
            <i class="bi bi-journal-check me-2"></i>Examora
        </a>
        <hr class="sidebar-divider bg-white opacity-25">
        <ul class="sidebar-menu">
            <li>
                <a href="../AdminServlet?action=dashboard" class="active">
                    <i class="bi bi-speedometer2"></i>Dashboard
                </a>
            </li>
            <li>
                <a href="../QuizServlet?action=list">
                    <i class="bi bi-journal-text"></i>Kelola Quiz
                </a>
            </li>
            <li>
                <a href="../AdminServlet?action=users">
                    <i class="bi bi-people"></i>Kelola User
                </a>
            </li>
            <li>
                <a href="../AdminServlet?action=statistics">
                    <i class="bi bi-graph-up"></i>Statistik
                </a>
            </li>
            <li class="mt-5">
                <a href="../LogoutServlet">
                    <i class="bi bi-box-arrow-left"></i>Logout
                </a>
            </li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Dashboard Admin</h1>
                <p class="text-muted mb-0">Selamat datang, <%= currentUser.getName() %></p>
            </div>
            <div>
                <a href="../QuizServlet?action=create" class="btn btn-primary">
                    <i class="bi bi-plus-lg me-2"></i>Buat Quiz Baru
                </a>
            </div>
        </div>

        <% if (success != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i><%= success %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Stats Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card stat-card bg-primary text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Total Peserta</p>
                                <h2 class="stat-value mb-0"><%= totalUsers != null ? totalUsers : 0 %></h2>
                            </div>
                            <i class="bi bi-people stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-success text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Total Quiz</p>
                                <h2 class="stat-value mb-0"><%= totalQuizzes != null ? totalQuizzes : 0 %></h2>
                            </div>
                            <i class="bi bi-journal-text stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-info text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Total Submissions</p>
                                <h2 class="stat-value mb-0"><%= totalSubmissions != null ? totalSubmissions : 0 %></h2>
                            </div>
                            <i class="bi bi-file-earmark-check stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-warning text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Total Admin</p>
                                <h2 class="stat-value mb-0"><%= totalAdmins != null ? totalAdmins : 0 %></h2>
                            </div>
                            <i class="bi bi-person-badge stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Recent Quizzes -->
        <div class="row g-4">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="bi bi-journal-text me-2"></i>Quiz Terbaru</h5>
                        <a href="../QuizServlet?action=list" class="btn btn-sm btn-outline-primary">Lihat Semua</a>
                    </div>
                    <div class="card-body">
                        <% if (quizzes != null && !quizzes.isEmpty()) { %>
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Judul</th>
                                        <th>Durasi</th>
                                        <th>Soal</th>
                                        <th>Status</th>
                                        <th>Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Object q : quizzes) {
                                        com.examora.model.Quiz quiz = (com.examora.model.Quiz) q;
                                    %>
                                    <tr>
                                        <td><%= quiz.getTitle() %></td>
                                        <td><%= quiz.getDuration() %> menit</td>
                                        <td><%= quiz.getQuestionCount() %> soal</td>
                                        <td>
                                            <% if (quiz.getIsActive()) { %>
                                            <span class="badge bg-success">Published</span>
                                            <% } else { %>
                                            <span class="badge bg-secondary">Draft</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <a href="../QuizServlet?action=view&id=<%= quiz.getId() %>"
                                               class="btn btn-sm btn-outline-info" title="Lihat">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            <a href="../QuestionServlet?action=list&quizId=<%= quiz.getId() %>"
                                               class="btn btn-sm btn-outline-primary" title="Edit Soal">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <% } else { %>
                        <div class="text-center py-4 text-muted">
                            <i class="bi bi-journal-x display-4 d-block mb-2"></i>
                            Belum ada quiz. <a href="../QuizServlet?action=create">Buat quiz pertama</a>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-lightning me-2"></i>Aksi Cepat</h5>
                    </div>
                    <div class="card-body">
                        <div class="d-grid gap-2">
                            <a href="../QuizServlet?action=create" class="btn btn-outline-primary">
                                <i class="bi bi-plus-circle me-2"></i>Buat Quiz Baru
                            </a>
                            <a href="../AdminServlet?action=users" class="btn btn-outline-success">
                                <i class="bi bi-people me-2"></i>Kelola User
                            </a>
                            <a href="../AdminServlet?action=statistics" class="btn btn-outline-info">
                                <i class="bi bi-graph-up me-2"></i>Lihat Statistik
                            </a>
                        </div>
                    </div>
                </div>

                <div class="card mt-4">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>Informasi</h5>
                    </div>
                    <div class="card-body">
                        <p class="text-muted small mb-2">
                            <i class="bi bi-person-badge me-2"></i>
                            Login sebagai: <strong><%= currentUser.getEmail() %></strong>
                        </p>
                        <p class="text-muted small mb-2">
                            <i class="bi bi-shield-check me-2"></i>
                            Role: <span class="badge bg-primary">Admin</span>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
