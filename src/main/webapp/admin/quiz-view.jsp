<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Quiz" %>
<%@ page import="com.examora.model.Question" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    Quiz quiz = (Quiz) request.getAttribute("quiz");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    if (quiz == null) {
        response.sendRedirect("../QuizServlet?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail Quiz - <%= quiz.getTitle() %> - Examora</title>
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
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Detail Quiz</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="../AdminServlet?action=dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="../QuizServlet?action=list">Quiz</a></li>
                        <li class="breadcrumb-item active"><%= quiz.getTitle() %></li>
                    </ol>
                </nav>
            </div>
            <div class="d-flex gap-2">
                <a href="../QuizServlet?action=edit&id=<%= quiz.getId() %>" class="btn btn-outline-primary">
                    <i class="bi bi-pencil me-2"></i>Edit Quiz
                </a>
                <a href="../QuestionServlet?action=list&quizId=<%= quiz.getId() %>" class="btn btn-outline-success">
                    <i class="bi bi-list-check me-2"></i>Kelola Soal
                </a>
                <a href="../QuizServlet?action=list" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>Kembali
                </a>
            </div>
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

        <!-- Quiz Info -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>Informasi Quiz</h5>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-2 fw-bold">Judul</div>
                    <div class="col-md-10"><%= quiz.getTitle() %></div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-2 fw-bold">Deskripsi</div>
                    <div class="col-md-10"><%= quiz.getDescription() != null && !quiz.getDescription().isEmpty() ? quiz.getDescription() : "-" %></div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-2 fw-bold">Durasi</div>
                    <div class="col-md-4"><%= quiz.getDuration() %> menit</div>
                    <div class="col-md-2 fw-bold">Jumlah Soal</div>
                    <div class="col-md-4"><%= questions != null ? questions.size() : 0 %> soal</div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-2 fw-bold">Deadline</div>
                    <div class="col-md-4">
                        <% if (quiz.getDeadline() != null) { %>
                            <% if (quiz.isExpired()) { %>
                            <span class="badge bg-danger">
                                <i class="bi bi-clock me-1"></i>Expired
                            </span>
                            <%= quiz.getFormattedDeadline() %>
                            <% } else { %>
                            <span class="badge bg-warning text-dark">
                                <i class="bi bi-clock me-1"></i><%= quiz.getFormattedDeadline() %>
                            </span>
                            <% } %>
                        <% } else { %>
                        <span class="text-muted">Tidak ada deadline</span>
                        <% } %>
                    </div>
                    <div class="col-md-2 fw-bold">Status</div>
                    <div class="col-md-4">
                        <% if (quiz.getIsActive()) { %>
                            <% if (quiz.isExpired()) { %>
                            <span class="badge bg-secondary">Expired</span>
                            <% } else { %>
                            <span class="badge bg-success">Published</span>
                            <% } %>
                        <% } else { %>
                        <span class="badge bg-secondary">Draft</span>
                        <% } %>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-md-2 fw-bold">Target Peserta</div>
                    <div class="col-md-10">
                        <% if (quiz.getTargetTag() != null && !quiz.getTargetTag().isEmpty()) {
                            String[] targetTags = quiz.getTargetTag().split(",");
                            for (String tag : targetTags) { %>
                        <span class="badge bg-primary me-1"><i class="bi bi-tag me-1"></i><%= tag.trim() %></span>
                        <% }
                        } else { %>
                        <span class="badge bg-secondary">Semua Peserta</span>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Questions List -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h6 class="mb-0"><i class="bi bi-list-check me-2"></i>Daftar Soal (<%= questions != null ? questions.size() : 0 %>)</h6>
            </div>
            <div class="card-body">
                <% if (questions != null && !questions.isEmpty()) { %>
                    <% for (int i = 0; i < questions.size(); i++) {
                        Question q = questions.get(i);
                    %>
                    <div class="card mb-3 border">
                        <div class="card-header bg-light py-2">
                            <span class="badge bg-primary me-2"><%= i + 1 %></span>
                            Soal #<%= i + 1 %>
                        </div>
                        <div class="card-body">
                            <p class="fw-bold mb-3"><%= q.getQuestionText() %></p>
                            <div class="row">
                                <div class="col-md-6 mb-2">
                                    <div class="p-2 border rounded <%= "A".equals(q.getCorrectAnswer()) ? "bg-success bg-opacity-10 border-success" : "" %>">
                                        <strong>A.</strong> <%= q.getOptionA() %>
                                        <% if ("A".equals(q.getCorrectAnswer())) { %>
                                        <i class="bi bi-check-circle-fill text-success ms-2"></i>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-2">
                                    <div class="p-2 border rounded <%= "B".equals(q.getCorrectAnswer()) ? "bg-success bg-opacity-10 border-success" : "" %>">
                                        <strong>B.</strong> <%= q.getOptionB() %>
                                        <% if ("B".equals(q.getCorrectAnswer())) { %>
                                        <i class="bi bi-check-circle-fill text-success ms-2"></i>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-2">
                                    <div class="p-2 border rounded <%= "C".equals(q.getCorrectAnswer()) ? "bg-success bg-opacity-10 border-success" : "" %>">
                                        <strong>C.</strong> <%= q.getOptionC() %>
                                        <% if ("C".equals(q.getCorrectAnswer())) { %>
                                        <i class="bi bi-check-circle-fill text-success ms-2"></i>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-2">
                                    <div class="p-2 border rounded <%= "D".equals(q.getCorrectAnswer()) ? "bg-success bg-opacity-10 border-success" : "" %>">
                                        <strong>D.</strong> <%= q.getOptionD() %>
                                        <% if ("D".equals(q.getCorrectAnswer())) { %>
                                        <i class="bi bi-check-circle-fill text-success ms-2"></i>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                <% } else { %>
                <div class="text-center py-5">
                    <i class="bi bi-question-circle display-1 text-muted mb-3 d-block"></i>
                    <h4 class="text-muted">Belum ada soal</h4>
                    <p class="text-muted">Mulai dengan menambahkan soal pertama</p>
                    <a href="../QuestionServlet?action=create&quizId=<%= quiz.getId() %>" class="btn btn-primary">
                        <i class="bi bi-plus-lg me-2"></i>Tambah Soal
                    </a>
                </div>
                <% } %>
            </div>
        </div>

        <% if (questions != null && !questions.isEmpty() && !quiz.getIsActive()) { %>
        <div class="text-center mt-4">
            <a href="../QuizServlet?action=publish&id=<%= quiz.getId() %>" class="btn btn-success btn-lg"
               onclick="return confirm('Publish quiz ini? Peserta akan dapat mengerjakan quiz.')">
                <i class="bi bi-play-circle me-2"></i>Publish Quiz
            </a>
        </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
