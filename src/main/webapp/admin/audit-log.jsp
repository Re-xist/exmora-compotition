<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.AuditLog" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    List<AuditLog> logs = (List<AuditLog>) request.getAttribute("logs");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    String actionType = (String) request.getAttribute("actionType");
    String entityType = (String) request.getAttribute("entityType");
    String status = (String) request.getAttribute("status");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Log - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0"><i class="bi bi-clipboard-data me-2"></i>Audit Log</h1>
                <p class="text-muted mb-0">Riwayat aktivitas sistem</p>
            </div>
        </div>

        <% if (success != null) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i><%= success %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="AuditServlet" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">Action Type</label>
                        <select class="form-select" name="actionType">
                            <option value="">Semua</option>
                            <option value="CREATE" <%= "CREATE".equals(actionType) ? "selected" : "" %>>CREATE</option>
                            <option value="UPDATE" <%= "UPDATE".equals(actionType) ? "selected" : "" %>>UPDATE</option>
                            <option value="DELETE" <%= "DELETE".equals(actionType) ? "selected" : "" %>>DELETE</option>
                            <option value="LOGIN" <%= "LOGIN".equals(actionType) ? "selected" : "" %>>LOGIN</option>
                            <option value="LOGOUT" <%= "LOGOUT".equals(actionType) ? "selected" : "" %>>LOGOUT</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Entity Type</label>
                        <select class="form-select" name="entityType">
                            <option value="">Semua</option>
                            <option value="USER" <%= "USER".equals(entityType) ? "selected" : "" %>>USER</option>
                            <option value="QUIZ" <%= "QUIZ".equals(entityType) ? "selected" : "" %>>QUIZ</option>
                            <option value="QUESTION" <%= "QUESTION".equals(entityType) ? "selected" : "" %>>QUESTION</option>
                            <option value="ATTENDANCE" <%= "ATTENDANCE".equals(entityType) ? "selected" : "" %>>ATTENDANCE</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Status</label>
                        <select class="form-select" name="status">
                            <option value="">Semua</option>
                            <option value="SUCCESS" <%= "SUCCESS".equals(status) ? "selected" : "" %>>SUCCESS</option>
                            <option value="FAILED" <%= "FAILED".equals(status) ? "selected" : "" %>>FAILED</option>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-search me-2"></i>Filter
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0"><i class="bi bi-list-ul me-2"></i>Log Aktivitas (<%= totalCount != null ? totalCount : 0 %> entries)</h5>
            </div>
            <div class="card-body">
                <% if (logs != null && !logs.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover table-sm">
                        <thead>
                            <tr>
                                <th>Waktu</th>
                                <th>Action</th>
                                <th>Entity</th>
                                <th>User</th>
                                <th>IP Address</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (AuditLog log : logs) { %>
                            <tr>
                                <td><small><%= log.getCreatedAt() != null ? log.getCreatedAt().format(dtf) : "-" %></small></td>
                                <td><span class="badge <%= log.getActionBadgeClass() %>"><%= log.getActionType() %></span></td>
                                <td>
                                    <strong><%= log.getEntityType() %></strong>
                                    <% if (log.getEntityName() != null) { %>
                                    <br><small class="text-muted"><%= log.getEntityName() %></small>
                                    <% } %>
                                </td>
                                <td><%= log.getUserName() %></td>
                                <td><small><%= log.getIpAddress() != null ? log.getIpAddress() : "-" %></small></td>
                                <td>
                                    <% if ("SUCCESS".equals(log.getStatus())) { %>
                                    <span class="badge bg-success">Success</span>
                                    <% } else { %>
                                    <span class="badge bg-danger">Failed</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <% if (totalPages != null && totalPages > 1) { %>
                <nav class="mt-3">
                    <ul class="pagination justify-content-center">
                        <% if (currentPage > 1) { %>
                        <li class="page-item">
                            <a class="page-link" href="?page=<%= currentPage - 1 %>&actionType=<%= actionType != null ? actionType : "" %>&entityType=<%= entityType != null ? entityType : "" %>&status=<%= status != null ? status : "" %>">Previous</a>
                        </li>
                        <% } %>
                        <% for (int i = 1; i <= totalPages; i++) { %>
                        <li class="page-item <%= i == currentPage ? "active" : "" %>">
                            <a class="page-link" href="?page=<%= i %>&actionType=<%= actionType != null ? actionType : "" %>&entityType=<%= entityType != null ? entityType : "" %>&status=<%= status != null ? status : "" %>"><%= i %></a>
                        </li>
                        <% } %>
                        <% if (currentPage < totalPages) { %>
                        <li class="page-item">
                            <a class="page-link" href="?page=<%= currentPage + 1 %>&actionType=<%= actionType != null ? actionType : "" %>&entityType=<%= entityType != null ? entityType : "" %>&status=<%= status != null ? status : "" %>">Next</a>
                        </li>
                        <% } %>
                    </ul>
                </nav>
                <% } %>
                <% } else { %>
                <div class="text-center py-4 text-muted">
                    <i class="bi bi-clipboard-x display-4 d-block mb-2"></i>
                    Tidak ada log ditemukan
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
