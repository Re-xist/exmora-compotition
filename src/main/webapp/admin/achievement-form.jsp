<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Achievement" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    Achievement achievement = (Achievement) request.getAttribute("achievement");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    boolean isEdit = achievement != null;
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Buat" %> Achievement - Examora</title>
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
                    <i class="bi bi-trophy me-2"></i><%= isEdit ? "Edit" : "Buat" %> Achievement
                </h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="../AdminServlet?action=dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="../AchievementServlet?action=list">Achievements</a></li>
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
                <form action="../AchievementServlet" method="post">
                    <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
                    <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>" />
                    <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= achievement.getId() %>" />
                    <% } %>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Nama Achievement *</label>
                                <input type="text" class="form-control" name="name" required
                                       value="<%= isEdit ? achievement.getName() : "" %>"
                                       placeholder="Contoh: Perfect Score">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Kategori *</label>
                                <select class="form-select" name="category" required>
                                    <option value="score" <%= isEdit && "score".equals(achievement.getCategory()) ? "selected" : "" %>>Score</option>
                                    <option value="speed" <%= isEdit && "speed".equals(achievement.getCategory()) ? "selected" : "" %>>Speed</option>
                                    <option value="quantity" <%= isEdit && "quantity".equals(achievement.getCategory()) ? "selected" : "" %>>Quantity</option>
                                    <option value="special" <%= isEdit && "special".equals(achievement.getCategory()) ? "selected" : "" %>>Special</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Deskripsi</label>
                        <textarea class="form-control" name="description" rows="3"
                                  placeholder="Deskripsi achievement..."><%= isEdit && achievement.getDescription() != null ? achievement.getDescription() : "" %></textarea>
                    </div>

                    <div class="row">
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label class="form-label">Icon (Bootstrap Icons)</label>
                                <input type="text" class="form-control" name="icon"
                                       value="<%= isEdit ? achievement.getIcon() : "bi-trophy" %>"
                                       placeholder="bi-trophy">
                                <small class="text-muted">Contoh: bi-trophy, bi-star, bi-lightning</small>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label class="form-label">Warna</label>
                                <select class="form-select" name="color">
                                    <option value="bg-warning" <%= isEdit && "bg-warning".equals(achievement.getColor()) ? "selected" : "" %>>Kuning (Gold)</option>
                                    <option value="bg-primary" <%= isEdit && "bg-primary".equals(achievement.getColor()) ? "selected" : "" %>>Biru</option>
                                    <option value="bg-success" <%= isEdit && "bg-success".equals(achievement.getColor()) ? "selected" : "" %>>Hijau</option>
                                    <option value="bg-danger" <%= isEdit && "bg-danger".equals(achievement.getColor()) ? "selected" : "" %>>Merah</option>
                                    <option value="bg-info" <%= isEdit && "bg-info".equals(achievement.getColor()) ? "selected" : "" %>>Cyan</option>
                                    <option value="bg-secondary" <%= isEdit && "bg-secondary".equals(achievement.getColor()) ? "selected" : "" %>>Abu-abu</option>
                                    <option value="bg-dark" <%= isEdit && "bg-dark".equals(achievement.getColor()) ? "selected" : "" %>>Hitam</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="mb-3">
                                <label class="form-label">Points</label>
                                <input type="number" class="form-control" name="points" min="0"
                                       value="<%= isEdit ? achievement.getPoints() : "10" %>">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Kondisi *</label>
                                <select class="form-select" name="conditionType" required>
                                    <option value="perfect_score" <%= isEdit && "perfect_score".equals(achievement.getConditionType()) ? "selected" : "" %>>Perfect Score (100)</option>
                                    <option value="high_score" <%= isEdit && "high_score".equals(achievement.getConditionType()) ? "selected" : "" %>>High Score (>= value)</option>
                                    <option value="quiz_count" <%= isEdit && "quiz_count".equals(achievement.getConditionType()) ? "selected" : "" %>>Jumlah Quiz Selesai</option>
                                    <option value="fast_completion" <%= isEdit && "fast_completion".equals(achievement.getConditionType()) ? "selected" : "" %>>Fast Completion (&lt; value% waktu)</option>
                                    <option value="first_quiz" <%= isEdit && "first_quiz".equals(achievement.getConditionType()) ? "selected" : "" %>>Quiz Pertama</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="form-label">Nilai Kondisi</label>
                                <input type="number" class="form-control" name="conditionValue" min="0"
                                       value="<%= isEdit ? achievement.getConditionValue() : "0" %>">
                                <small class="text-muted">
                                    Contoh: untuk High Score, isi 95 (berarti score >= 95)
                                </small>
                            </div>
                        </div>
                    </div>

                    <% if (isEdit) { %>
                    <div class="mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="isActive" id="isActive"
                                   <%= achievement.getIsActive() ? "checked" : "" %>>
                            <label class="form-check-label" for="isActive">
                                Achievement Aktif
                            </label>
                        </div>
                    </div>
                    <% } %>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i><%= isEdit ? "Update" : "Simpan" %>
                        </button>
                        <a href="../AchievementServlet?action=list" class="btn btn-secondary">
                            <i class="bi bi-x-lg me-1"></i>Batal
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Icon Preview -->
        <div class="card mt-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-eye me-2"></i>Preview Icon</h5>
            </div>
            <div class="card-body">
                <div class="d-flex flex-wrap gap-3">
                    <div class="text-center">
                        <span class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-trophy"></i>
                        </span>
                        <small class="d-block mt-1">bi-trophy</small>
                    </div>
                    <div class="text-center">
                        <span class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-star-fill"></i>
                        </span>
                        <small class="d-block mt-1">bi-star-fill</small>
                    </div>
                    <div class="text-center">
                        <span class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-lightning-fill"></i>
                        </span>
                        <small class="d-block mt-1">bi-lightning-fill</small>
                    </div>
                    <div class="text-center">
                        <span class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-award-fill"></i>
                        </span>
                        <small class="d-block mt-1">bi-award-fill</small>
                    </div>
                    <div class="text-center">
                        <span class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-fire"></i>
                        </span>
                        <small class="d-block mt-1">bi-fire</small>
                    </div>
                    <div class="text-center">
                        <span class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-gem"></i>
                        </span>
                        <small class="d-block mt-1">bi-gem</small>
                    </div>
                    <div class="text-center">
                        <span class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-flag-fill"></i>
                        </span>
                        <small class="d-block mt-1">bi-flag-fill</small>
                    </div>
                    <div class="text-center">
                        <span class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-bookmark-star-fill"></i>
                        </span>
                        <small class="d-block mt-1">bi-bookmark-star-fill</small>
                    </div>
                </div>
                <p class="text-muted small mt-3">
                    <i class="bi bi-info-circle me-1"></i>
                    Lihat icon lainnya di <a href="https://icons.getbootstrap.com/" target="_blank">Bootstrap Icons</a>
                </p>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
