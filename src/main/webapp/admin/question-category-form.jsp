<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.QuestionCategory" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    QuestionCategory category = (QuestionCategory) request.getAttribute("category");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    boolean isEdit = category != null;
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Buat" %> Kategori Soal - Examora</title>
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
                    <i class="bi bi-collection me-2"></i><%= isEdit ? "Edit" : "Buat" %> Kategori Soal
                </h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="../AdminServlet?action=dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="../QuestionBankServlet?action=categories">Bank Soal</a></li>
                        <li class="breadcrumb-item active"><%= isEdit ? "Edit" : "Buat" %></li>
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
                    <input type="hidden" name="action" value="<%= isEdit ? "updateCategory" : "createCategory" %>" />
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= category.getId() %>" />
                    <% } %>

                    <div class="mb-3">
                        <label class="form-label">Nama Kategori *</label>
                        <input type="text" class="form-control" name="name" required
                               value="<%= isEdit ? category.getName() : "" %>"
                               placeholder="Contoh: Networking, Programming, Security">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Deskripsi</label>
                        <textarea class="form-control" name="description" rows="3"
                                  placeholder="Deskripsi kategori..."><%= isEdit && category.getDescription() != null ? category.getDescription() : "" %></textarea>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i><%= isEdit ? "Update" : "Simpan" %>
                        </button>
                        <a href="../QuestionBankServlet?action=categories" class="btn btn-secondary">
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
