<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Achievement" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    List<Achievement> achievements = (List<Achievement>) request.getAttribute("achievements");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Achievements - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0"><i class="bi bi-trophy me-2"></i>Achievements</h1>
                <p class="text-muted mb-0">Kelola achievement dan badge untuk peserta</p>
            </div>
            <div>
                <a href="AchievementServlet?action=create" class="btn btn-primary">
                    <i class="bi bi-plus-lg me-2"></i>Achievement Baru
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
            <% if (achievements != null && !achievements.isEmpty()) { %>
                <% for (Achievement a : achievements) { %>
                <div class="col-md-4 col-lg-3 mb-4">
                    <div class="card h-100 <%= a.getIsActive() ? "" : "opacity-50" %>">
                        <div class="card-body text-center">
                            <div class="mb-3">
                                <span class="<%= a.getColor() %> text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 60px; height: 60px;">
                                    <i class="bi <%= a.getIcon() %> fs-3"></i>
                                </span>
                            </div>
                            <h5 class="card-title"><%= a.getName() %></h5>
                            <p class="card-text small text-muted"><%= a.getDescription() != null && a.getDescription().length() > 60 ? a.getDescription().substring(0, 60) + "..." : a.getDescription() %></p>
                            <div class="mb-2">
                                <span class="badge bg-secondary"><%= a.getCategoryDisplayName() %></span>
                                <span class="badge bg-warning text-dark">+<%= a.getPoints() %> pts</span>
                            </div>
                            <div class="small text-muted mb-2">
                                <i class="bi bi-gear me-1"></i><%= a.getConditionType() %> >= <%= a.getConditionValue() %>
                            </div>
                            <div class="btn-group btn-group-sm">
                                <a href="AchievementServlet?action=edit&id=<%= a.getId() %>" class="btn btn-outline-warning" title="Edit">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <a href="AchievementServlet?action=toggle&id=<%= a.getId() %>" class="btn btn-outline-<%= a.getIsActive() ? "secondary" : "success" %>" title="<%= a.getIsActive() ? "Nonaktifkan" : "Aktifkan" %>">
                                    <i class="bi bi-<%= a.getIsActive() ? "toggle-on" : "toggle-off" %>"></i>
                                </a>
                                <a href="AchievementServlet?action=delete&id=<%= a.getId() %>" class="btn btn-outline-danger" title="Hapus"
                                   onclick="return confirm('Yakin ingin menghapus achievement ini?')">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            <% } else { %>
            <div class="col-12">
                <div class="card">
                    <div class="card-body text-center py-5">
                        <i class="bi bi-trophy display-1 text-muted mb-3 d-block"></i>
                        <h5 class="text-muted">Belum ada achievement</h5>
                        <p class="text-muted">Buat achievement pertama untuk memulai gamification.</p>
                        <a href="AchievementServlet?action=create" class="btn btn-primary">
                            <i class="bi bi-plus-lg me-2"></i>Buat Achievement
                        </a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
