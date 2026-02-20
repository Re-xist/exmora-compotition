<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.QuestionCategory" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    List<QuestionCategory> categories = (List<QuestionCategory>) request.getAttribute("categories");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
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
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0"><i class="bi bi-collection me-2"></i>Bank Soal</h1>
                <p class="text-muted mb-0">Kelola kategori dan soal untuk digunakan ulang</p>
            </div>
            <div>
                <a href="QuestionBankServlet?action=createCategory" class="btn btn-success">
                    <i class="bi bi-plus-lg me-2"></i>Kategori Baru
                </a>
                <a href="QuestionBankServlet?action=questions" class="btn btn-primary">
                    <i class="bi bi-list-check me-2"></i>Lihat Soal
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

        <div class="row">
            <div class="col-12">
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="bi bi-folder me-2"></i>Kategori Soal</h5>
                    </div>
                    <div class="card-body">
                        <% if (categories != null && !categories.isEmpty()) { %>
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Nama Kategori</th>
                                        <th>Deskripsi</th>
                                        <th>Jumlah Soal</th>
                                        <th>Dibuat Oleh</th>
                                        <th>Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (QuestionCategory cat : categories) { %>
                                    <tr>
                                        <td><strong><%= cat.getName() %></strong></td>
                                        <td><%= cat.getDescription() != null && cat.getDescription().length() > 50 ?
                                            cat.getDescription().substring(0, 50) + "..." : (cat.getDescription() != null ? cat.getDescription() : "-") %></td>
                                        <td><span class="badge bg-primary"><%= cat.getQuestionCount() != null ? cat.getQuestionCount() : 0 %> soal</span></td>
                                        <td><%= cat.getCreatedByName() != null ? cat.getCreatedByName() : "-" %></td>
                                        <td>
                                            <a href="QuestionBankServlet?action=questions&categoryId=<%= cat.getId() %>"
                                               class="btn btn-sm btn-outline-primary" title="Lihat Soal">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            <a href="QuestionBankServlet?action=editCategory&id=<%= cat.getId() %>"
                                               class="btn btn-sm btn-outline-warning" title="Edit">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                            <a href="QuestionBankServlet?action=deleteCategory&id=<%= cat.getId() %>"
                                               class="btn btn-sm btn-outline-danger" title="Hapus"
                                               onclick="return confirm('Yakin ingin menghapus kategori ini?')">
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
                            <i class="bi bi-folder-x display-4 d-block mb-2"></i>
                            Belum ada kategori soal. <a href="QuestionBankServlet?action=createCategory">Buat kategori pertama</a>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
