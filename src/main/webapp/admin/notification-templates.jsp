<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.NotificationTemplate" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    List<NotificationTemplate> templates = (List<NotificationTemplate>) request.getAttribute("templates");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifikasi - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0"><i class="bi bi-envelope me-2"></i>Notifikasi</h1>
                <p class="text-muted mb-0">Kelola template email dan antrian notifikasi</p>
            </div>
            <div>
                <a href="NotificationServlet?action=queue" class="btn btn-outline-primary">
                    <i class="bi bi-list-ul me-2"></i>Lihat Antrian
                </a>
                <a href="NotificationServlet?action=createTemplate" class="btn btn-primary">
                    <i class="bi bi-plus-lg me-2"></i>Template Baru
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

        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-file-earmark-text me-2"></i>Template Email</h5>
            </div>
            <div class="card-body">
                <% if (templates != null && !templates.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Nama</th>
                                <th>Subject</th>
                                <th>Tipe</th>
                                <th>Status</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (NotificationTemplate t : templates) { %>
                            <tr>
                                <td><strong><%= t.getName() %></strong></td>
                                <td><%= t.getSubject() %></td>
                                <td><span class="badge bg-info"><%= t.getTypeDisplayName() %></span></td>
                                <td>
                                    <% if (t.getIsActive()) { %>
                                    <span class="badge bg-success">Aktif</span>
                                    <% } else { %>
                                    <span class="badge bg-secondary">Nonaktif</span>
                                    <% } %>
                                </td>
                                <td>
                                    <a href="NotificationServlet?action=editTemplate&id=<%= t.getId() %>"
                                       class="btn btn-sm btn-outline-warning" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                    <a href="NotificationServlet?action=deleteTemplate&id=<%= t.getId() %>"
                                       class="btn btn-sm btn-outline-danger" title="Hapus"
                                       onclick="return confirm('Yakin ingin menghapus template ini?')">
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
                    <i class="bi bi-envelope-x display-4 d-block mb-2"></i>
                    Belum ada template email.
                </div>
                <% } %>
            </div>
        </div>

        <!-- Email Configuration Status -->
        <div class="card mt-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-gear me-2"></i>Konfigurasi Email</h5>
            </div>
            <div class="card-body">
                <p class="text-muted">
                    <i class="bi bi-info-circle me-2"></i>
                    Konfigurasi email SMTP dapat diatur di file <code>db.properties</code>:
                </p>
                <ul class="small text-muted">
                    <li><code>email.smtp.host</code> - SMTP server (contoh: smtp.gmail.com)</li>
                    <li><code>email.smtp.port</code> - Port SMTP (contoh: 587)</li>
                    <li><code>email.username</code> - Username email</li>
                    <li><code>email.password</code> - Password/App Password</li>
                </ul>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
