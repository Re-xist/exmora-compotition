<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.ArenaSession" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    List<ArenaSession> arenas = (List<ArenaSession>) request.getAttribute("arenas");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Arena - Examora</title>
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
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Kelola Arena</h1>
                <p class="text-muted mb-0">Daftar arena competitive quiz</p>
            </div>
            <div>
                <a href="../ArenaServlet?action=create" class="btn btn-arena">
                    <i class="bi bi-plus-lg me-2"></i>Buat Arena Baru
                </a>
            </div>
        </div>

        <% if (success != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i><%= success %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- Arena List -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-trophy me-2"></i>Daftar Arena</h5>
            </div>
            <div class="card-body">
                <% if (arenas != null && !arenas.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Kode</th>
                                <th>Quiz</th>
                                <th>Host</th>
                                <th>Peserta</th>
                                <th>Status</th>
                                <th>Dibuat</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (ArenaSession arena : arenas) { %>
                            <tr>
                                <td>
                                    <span class="badge bg-arena-code"><%= arena.getCode() %></span>
                                </td>
                                <td><%= arena.getQuizTitle() %></td>
                                <td><%= arena.getHostName() %></td>
                                <td>
                                    <span class="badge bg-secondary">
                                        <i class="bi bi-people me-1"></i><%= arena.getParticipantCount() %>
                                    </span>
                                </td>
                                <td>
                                    <% if ("waiting".equals(arena.getStatus())) { %>
                                    <span class="badge bg-warning text-dark">Menunggu</span>
                                    <% } else if ("active".equals(arena.getStatus())) { %>
                                    <span class="badge bg-success">Berjalan</span>
                                    <% } else if ("paused".equals(arena.getStatus())) { %>
                                    <span class="badge bg-info">Dijeda</span>
                                    <% } else { %>
                                    <span class="badge bg-secondary">Selesai</span>
                                    <% } %>
                                </td>
                                <td>
                                    <small class="text-muted">
                                        <%= arena.getCreatedAt() != null ?
                                            arena.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("dd MMM HH:mm")) : "-" %>
                                    </small>
                                </td>
                                <td>
                                    <% if (!"completed".equals(arena.getStatus())) { %>
                                    <a href="../ArenaServlet?action=host&id=<%= arena.getId() %>"
                                       class="btn btn-sm btn-outline-arena" title="Host Panel">
                                        <i class="bi bi-broadcast"></i>
                                    </a>
                                    <% } else { %>
                                    <a href="../ArenaServlet?action=result&id=<%= arena.getId() %>"
                                       class="btn btn-sm btn-outline-info" title="Lihat Hasil">
                                        <i class="bi bi-bar-chart"></i>
                                    </a>
                                    <% } %>
                                    <% if ("waiting".equals(arena.getStatus()) || "completed".equals(arena.getStatus())) { %>
                                    <a href="../ArenaServlet?action=delete&id=<%= arena.getId() %>"
                                       class="btn btn-sm btn-outline-danger"
                                       title="Hapus"
                                       onclick="return confirm('Yakin ingin menghapus arena ini?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-trophy display-4 d-block mb-3"></i>
                    <p>Belum ada arena. <a href="../ArenaServlet?action=create">Buat arena pertama</a></p>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
