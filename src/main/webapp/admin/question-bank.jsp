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
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    List<QuestionCategory> categories = (List<QuestionCategory>) request.getAttribute("categories");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    String search = request.getParameter("search");
    String categoryId = request.getParameter("categoryId");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Soal - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0"><i class="bi bi-collection me-2"></i>Bank Soal</h1>
                <p class="text-muted mb-0">Daftar soal yang tersedia untuk digunakan ulang</p>
            </div>
            <div>
                <a href="QuestionBankServlet?action=createQuestion" class="btn btn-primary">
                    <i class="bi bi-plus-lg me-2"></i>Tambah Soal
                </a>
                <a href="QuestionBankServlet?action=categories" class="btn btn-outline-secondary">
                    <i class="bi bi-folder me-2"></i>Kategori
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

        <!-- Search and Filter -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="QuestionBankServlet" class="row g-3">
                    <input type="hidden" name="action" value="questions">
                    <div class="col-md-5">
                        <input type="text" class="form-control" name="search" placeholder="Cari soal..."
                               value="<%= search != null ? search : "" %>">
                    </div>
                    <div class="col-md-4">
                        <select class="form-select" name="categoryId">
                            <option value="">Semua Kategori</option>
                            <% if (categories != null) { for (QuestionCategory cat : categories) { %>
                            <option value="<%= cat.getId() %>" <%= categoryId != null && categoryId.equals(String.valueOf(cat.getId())) ? "selected" : "" %>>
                                <%= cat.getName() %>
                            </option>
                            <% }} %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-search me-2"></i>Cari
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-list-ul me-2"></i>Daftar Soal (<%= questions != null ? questions.size() : 0 %> soal)</h5>
            </div>
            <div class="card-body">
                <% if (questions != null && !questions.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th width="40%">Pertanyaan</th>
                                <th>Kategori</th>
                                <th>Jawaban</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Question q : questions) { %>
                            <tr>
                                <td><%= q.getQuestionText() != null && q.getQuestionText().length() > 80 ?
                                    q.getQuestionText().substring(0, 80) + "..." : q.getQuestionText() %></td>
                                <td><span class="badge bg-secondary"><%= q.getCategoryName() != null ? q.getCategoryName() : "Tidak ada" %></span></td>
                                <td><span class="badge bg-success"><%= q.getCorrectAnswer() %></span></td>
                                <td>
                                    <a href="QuestionBankServlet?action=editQuestion&id=<%= q.getId() %>"
                                       class="btn btn-sm btn-outline-warning" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <a href="QuestionBankServlet?action=deleteQuestion&id=<%= q.getId() %>"
                                       class="btn btn-sm btn-outline-danger" title="Hapus"
                                       onclick="return confirm('Yakin ingin menghapus soal ini?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-4 text-muted">
                    <i class="bi bi-question-circle display-4 d-block mb-2"></i>
                    Belum ada soal di bank. <a href="QuestionBankServlet?action=createQuestion">Tambah soal pertama</a>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
