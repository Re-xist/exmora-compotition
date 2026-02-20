<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.NotificationTemplate" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    NotificationTemplate template = (NotificationTemplate) request.getAttribute("template");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    boolean isEdit = template != null;
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Buat" %> Template Notifikasi - Examora</title>
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
                    <i class="bi bi-envelope me-2"></i><%= isEdit ? "Edit" : "Buat" %> Template Notifikasi
                </h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="../AdminServlet?action=dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="../NotificationServlet?action=templates">Notifikasi</a></li>
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
                <form action="../NotificationServlet" method="post">
                    <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
                    <input type="hidden" name="action" value="<%= isEdit ? "updateTemplate" : "createTemplate" %>" />
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= template.getId() %>" />
                    <% } %>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Nama Template *</label>
                                <input type="text" class="form-control" name="name" required
                                       value="<%= isEdit ? template.getName() : "" %>"
                                       placeholder="Contoh: Quiz Baru">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Tipe *</label>
                                <select class="form-select" name="type" required>
                                    <option value="new_quiz" <%= isEdit && "new_quiz".equals(template.getType()) ? "selected" : "" %>>Quiz Baru</option>
                                    <option value="deadline_reminder" <%= isEdit && "deadline_reminder".equals(template.getType()) ? "selected" : "" %>>Pengingat Deadline</option>
                                    <option value="result" <%= isEdit && "result".equals(template.getType()) ? "selected" : "" %>>Hasil Quiz</option>
                                    <option value="general" <%= isEdit && "general".equals(template.getType()) ? "selected" : "" %>>Umum</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Subject Email *</label>
                        <input type="text" class="form-control" name="subject" required
                               value="<%= isEdit ? template.getSubject() : "" %>"
                               placeholder="Contoh: Quiz Baru Tersedia: {quiz_name}">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Body Email *</label>
                        <textarea class="form-control" name="body" rows="10" required
                                  placeholder="Halo {user_name},&#10;&#10;Quiz baru telah tersedia..."><%= isEdit && template.getBody() != null ? template.getBody() : "" %></textarea>
                        <small class="text-muted">
                            Variables: {user_name}, {quiz_name}, {score}, {deadline}, {date}
                        </small>
                    </div>

                    <% if (isEdit) { %>
                    <div class="mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="isActive" id="isActive"
                                   <%= template.getIsActive() ? "checked" : "" %>>
                            <label class="form-check-label" for="isActive">
                                Template Aktif
                            </label>
                        </div>
                    </div>
                    <% } %>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i><%= isEdit ? "Update" : "Simpan" %>
                        </button>
                        <a href="../NotificationServlet?action=templates" class="btn btn-secondary">
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
