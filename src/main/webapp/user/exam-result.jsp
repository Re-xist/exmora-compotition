<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Submission" %>
<%@ page import="com.examora.model.Answer" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    Submission submission = (Submission) request.getAttribute("submission");
    if (submission == null) {
        response.sendRedirect("../ExamServlet?action=list");
        return;
    }
    List<Answer> answers = submission.getAnswers();

    // Determine score class
    String scoreClass = "poor";
    if (submission.getScore() >= 90) scoreClass = "excellent";
    else if (submission.getScore() >= 75) scoreClass = "good";
    else if (submission.getScore() >= 60) scoreClass = "average";

    String scoreMessage = "";
    if (submission.getScore() >= 90) scoreMessage = "Luar biasa! Performa sangat baik!";
    else if (submission.getScore() >= 75) scoreMessage = "Bagus! Anda lulus dengan baik.";
    else if (submission.getScore() >= 60) scoreMessage = "Cukup baik. Masih bisa ditingkatkan.";
    else scoreMessage = "Perlu belajar lebih giat lagi.";
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hasil Ujian - Examora</title>
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
                        <a class="nav-link" href="../ExamServlet?action=history">
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
    <div class="container py-5">
        <!-- Result Summary -->
        <div class="result-summary mb-5 fade-in">
            <div class="row align-items-center">
                <div class="col-md-6 text-center">
                    <h2 class="mb-3"><%= submission.getQuizTitle() %></h2>
                    <div class="score-display <%= scoreClass %>">
                        <%= String.format("%.0f", submission.getScore()) %>
                    </div>
                    <p class="lead mt-2"><%= scoreMessage %></p>
                </div>
                <div class="col-md-6">
                    <div class="row text-center">
                        <div class="col-4">
                            <div class="border-end">
                                <h4><%= submission.getTotalQuestions() %></h4>
                                <small class="opacity-75">Total Soal</small>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="border-end">
                                <h4 class="text-success"><%= submission.getCorrectAnswers() %></h4>
                                <small class="opacity-75">Benar</small>
                            </div>
                        </div>
                        <div class="col-4">
                            <h4 class="text-danger"><%= submission.getTotalQuestions() - submission.getCorrectAnswers() %></h4>
                            <small class="opacity-75">Salah</small>
                        </div>
                    </div>
                    <hr class="my-3 opacity-25">
                    <div class="row">
                        <div class="col-6">
                            <i class="bi bi-clock me-2"></i>Waktu: <%= submission.getFormattedTimeSpent() %>
                        </div>
                        <div class="col-6">
                            <i class="bi bi-calendar me-2"></i><%= submission.getSubmittedAt() != null ?
                                submission.getSubmittedAt().toLocalDate() : "-" %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons -->
        <div class="text-center mb-4">
            <a href="../ExamServlet?action=list" class="btn btn-primary btn-lg me-2">
                <i class="bi bi-journal-text me-2"></i>Quiz Lainnya
            </a>
            <a href="../ExamServlet?action=dashboard" class="btn btn-outline-primary btn-lg">
                <i class="bi bi-house me-2"></i>Dashboard
            </a>
        </div>

        <!-- Answer Review -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-list-check me-2"></i>Review Jawaban</h5>
            </div>
            <div class="card-body">
                <% if (answers != null && !answers.isEmpty()) {
                    for (int i = 0; i < answers.size(); i++) {
                        Answer ans = answers.get(i);
                        boolean isCorrect = ans.getIsCorrect() != null && ans.getIsCorrect();
                        String userAnswer = ans.getSelectedAnswer();
                        boolean hasAnswer = userAnswer != null && !userAnswer.isEmpty();
                %>
                <div class="card mb-3 border-<%= isCorrect ? "success" : "danger" %>">
                    <div class="card-header bg-<%= isCorrect ? "success" : "danger" %> text-white py-2">
                        <div class="d-flex justify-content-between align-items-center">
                            <span><strong>Soal #<%= i + 1 %></strong></span>
                            <span>
                                <% if (isCorrect) { %>
                                <i class="bi bi-check-circle-fill me-1"></i>Benar
                                <% } else { %>
                                <i class="bi bi-x-circle-fill me-1"></i>Salah
                                <% } %>
                            </span>
                        </div>
                    </div>
                    <div class="card-body">
                        <p class="mb-3"><%= ans.getQuestionText() != null ? ans.getQuestionText() : "Pertanyaan tidak tersedia" %></p>
                        <div class="row">
                            <div class="col-md-6">
                                <p class="mb-1">
                                    <strong>Jawaban Anda:</strong>
                                    <span class="<%= isCorrect ? "text-success" : "text-danger" %>">
                                        <%= hasAnswer ? userAnswer : "Tidak dijawab" %>
                                    </span>
                                </p>
                            </div>
                            <% if (!isCorrect || !hasAnswer) { %>
                            <div class="col-md-6">
                                <p class="mb-1">
                                    <strong>Jawaban Benar:</strong>
                                    <span class="text-success"><%= ans.getCorrectAnswer() != null ? ans.getCorrectAnswer() : "-" %></span>
                                </p>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% }
                } else { %>
                <div class="text-center py-4 text-muted">
                    <i class="bi bi-eye-slash display-4 d-block mb-2"></i>
                    Tidak ada detail jawaban tersedia.
                </div>
                <% } %>
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
</body>
</html>
