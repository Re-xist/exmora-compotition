<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Quiz - Examora</title>
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
            <li><a href="../AdminServlet?action=dashboard"><i class="bi bi-speedometer2"></i>Dashboard</a></li>
            <li><a href="../QuizServlet?action=list" class="active"><i class="bi bi-journal-text"></i>Kelola Quiz</a></li>
            <li><a href="../ArenaServlet?action=list"><i class="bi bi-trophy"></i>Kelola Arena</a></li>
            <li><a href="../AdminServlet?action=users"><i class="bi bi-people"></i>Kelola User</a></li>
            <li><a href="../AdminServlet?action=statistics"><i class="bi bi-graph-up"></i>Statistik</a></li>
            <li><a href="../SettingsServlet"><i class="bi bi-gear"></i>Pengaturan</a></li>
            <li class="mt-5"><a href="../LogoutServlet"><i class="bi bi-box-arrow-left"></i>Logout</a></li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Kelola Quiz</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="../AdminServlet?action=dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item active">Quiz</li>
                    </ol>
                </nav>
            </div>
            <a href="../QuizServlet?action=create" class="btn btn-primary">
                <i class="bi bi-plus-lg me-2"></i>Buat Quiz Baru
            </a>
        </div>

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

        <div class="card">
            <div class="card-body">
                <% if (quizzes != null && !quizzes.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Judul</th>
                                <th>Durasi</th>
                                <th>Soal</th>
                                <th>Target</th>
                                <th>Deadline</th>
                                <th>Status</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int no = 1; for (Quiz quiz : quizzes) { %>
                            <tr>
                                <td><%= no++ %></td>
                                <td>
                                    <strong><%= quiz.getTitle() %></strong>
                                    <% if (quiz.getDescription() != null && !quiz.getDescription().isEmpty()) { %>
                                    <br><small class="text-muted"><%= quiz.getDescription().length() > 50 ?
                                        quiz.getDescription().substring(0, 50) + "..." : quiz.getDescription() %></small>
                                    <% } %>
                                </td>
                                <td><%= quiz.getDuration() %> menit</td>
                                <td><span class="badge bg-info"><%= quiz.getQuestionCount() %> soal</span></td>
                                <td>
                                    <% if (quiz.getTargetTag() != null && !quiz.getTargetTag().isEmpty()) {
                                        String[] targetTags = quiz.getTargetTag().split(",");
                                        for (String tag : targetTags) { %>
                                    <span class="badge bg-primary me-1"><%= tag.trim() %></span>
                                    <% }
                                    } else { %>
                                    <span class="badge bg-secondary">Semua</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (quiz.getDeadline() != null) { %>
                                        <% if (quiz.isExpired()) { %>
                                        <span class="badge bg-danger">
                                            <i class="bi bi-clock me-1"></i>Expired
                                        </span>
                                        <br><small><%= quiz.getFormattedDeadline() %></small>
                                        <% } else { %>
                                        <span class="badge bg-warning text-dark">
                                            <i class="bi bi-clock me-1"></i><%= quiz.getFormattedDeadline() %>
                                        </span>
                                        <% } %>
                                    <% } else { %>
                                    <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (quiz.getIsActive()) { %>
                                        <% if (quiz.isExpired()) { %>
                                        <span class="badge bg-secondary">Expired</span>
                                        <% } else { %>
                                        <span class="badge bg-success">Published</span>
                                        <% } %>
                                    <% } else { %>
                                    <span class="badge bg-secondary">Draft</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm">
                                        <a href="../QuizServlet?action=view&id=<%= quiz.getId() %>"
                                           class="btn btn-outline-info" title="Lihat">
                                            <i class="bi bi-eye"></i>
                                        </a>
                                        <a href="../QuizServlet?action=edit&id=<%= quiz.getId() %>"
                                           class="btn btn-outline-primary" title="Edit">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <a href="../QuestionServlet?action=list&quizId=<%= quiz.getId() %>"
                                           class="btn btn-outline-success" title="Kelola Soal">
                                            <i class="bi bi-list-check"></i>
                                        </a>
                                        <% if (quiz.getIsActive()) { %>
                                        <a href="../QuizServlet?action=unpublish&id=<%= quiz.getId() %>"
                                           class="btn btn-outline-warning" title="Unpublish"
                                           onclick="return confirm('Unpublish quiz ini?')">
                                            <i class="bi bi-pause-circle"></i>
                                        </a>
                                        <% } else { %>
                                        <a href="../QuizServlet?action=publish&id=<%= quiz.getId() %>"
                                           class="btn btn-outline-success" title="Publish"
                                           onclick="return confirm('Publish quiz ini?')">
                                            <i class="bi bi-play-circle"></i>
                                        </a>
                                        <% } %>
                                        <a href="../QuizServlet?action=delete&id=<%= quiz.getId() %>"
                                           class="btn btn-outline-danger" title="Hapus"
                                           onclick="return confirm('Hapus quiz ini? Semua soal akan ikut terhapus.')">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-5">
                    <i class="bi bi-journal-x display-1 text-muted mb-3 d-block"></i>
                    <h4 class="text-muted">Belum ada quiz</h4>
                    <p class="text-muted">Mulai dengan membuat quiz pertama Anda</p>
                    <a href="../QuizServlet?action=create" class="btn btn-primary">
                        <i class="bi bi-plus-lg me-2"></i>Buat Quiz Baru
                    </a>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
