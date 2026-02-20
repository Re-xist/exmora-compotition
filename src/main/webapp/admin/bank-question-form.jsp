<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Question" %>
<%@ page import="com.examora.model.QuestionCategory" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    Question question = (Question) request.getAttribute("question");
    List<QuestionCategory> categories = (List<QuestionCategory>) request.getAttribute("categories");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    boolean isEdit = question != null;
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Tambah" %> Soal Bank - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">
                    <i class="bi bi-question-circle me-2"></i><%= isEdit ? "Edit" : "Tambah" %> Soal Bank
                </h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="../AdminServlet?action=dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="../QuestionBankServlet?action=categories">Bank Soal</a></li>
                        <li class="breadcrumb-item"><a href="../QuestionBankServlet?action=questions">Daftar Soal</a></li>
                        <li class="breadcrumb-item active"><%= isEdit ? "Edit" : "Tambah" %></li>
                    </ol>
                </nav>
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

        <div class="card">
            <div class="card-body">
                <form action="../QuestionBankServlet" method="post">
                    <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
                    <input type="hidden" name="action" value="<%= isEdit ? "updateQuestion" : "createQuestion" %>" />
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= question.getId() %>" />
                    <% } %>

                    <div class="mb-3">
                        <label class="form-label">Kategori</label>
                        <select class="form-select" name="categoryId">
                            <option value="">-- Tanpa Kategori --</option>
                            <% if (categories != null) {
                                for (QuestionCategory cat : categories) { %>
                            <option value="<%= cat.getId() %>"
                                <%= isEdit && question.getCategoryId() != null && question.getCategoryId().equals(cat.getId()) ? "selected" : "" %>>
                                <%= cat.getName() %>
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Pertanyaan *</label>
                        <textarea class="form-control" name="questionText" rows="3" required
                                  placeholder="Tulis pertanyaan..."><%= isEdit && question.getQuestionText() != null ? question.getQuestionText() : "" %></textarea>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Opsi A *</label>
                                <input type="text" class="form-control" name="optionA" required
                                       value="<%= isEdit && question.getOptionA() != null ? question.getOptionA() : "" %>">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Opsi B *</label>
                                <input type="text" class="form-control" name="optionB" required
                                       value="<%= isEdit && question.getOptionB() != null ? question.getOptionB() : "" %>">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Opsi C *</label>
                                <input type="text" class="form-control" name="optionC" required
                                       value="<%= isEdit && question.getOptionC() != null ? question.getOptionC() : "" %>">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Opsi D *</label>
                                <input type="text" class="form-control" name="optionD" required
                                       value="<%= isEdit && question.getOptionD() != null ? question.getOptionD() : "" %>">
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Jawaban Benar *</label>
                        <select class="form-select" name="correctAnswer" required>
                            <option value="A" <%= isEdit && "A".equals(question.getCorrectAnswer()) ? "selected" : "" %>>A</option>
                            <option value="B" <%= isEdit && "B".equals(question.getCorrectAnswer()) ? "selected" : "" %>>B</option>
                            <option value="C" <%= isEdit && "C".equals(question.getCorrectAnswer()) ? "selected" : "" %>>C</option>
                            <option value="D" <%= isEdit && "D".equals(question.getCorrectAnswer()) ? "selected" : "" %>>D</option>
                        </select>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i><%= isEdit ? "Update" : "Simpan" %>
                        </button>
                        <a href="../QuestionBankServlet?action=questions" class="btn btn-secondary">
                            <i class="bi bi-x-lg me-1"></i>Batal
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
