<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Quiz" %>
<%@ page import="com.examora.service.UserService" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.HashSet" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    Quiz quiz = (Quiz) request.getAttribute("quiz");
    boolean isEdit = quiz != null && quiz.getId() != null;
    String error = (String) request.getAttribute("error");

    // Get all tags
    UserService userService = new UserService();
    List<String> tags = null;
    try {
        tags = userService.getAllTags();
    } catch (Exception e) {
        // Ignore
    }

    // Format deadline for datetime-local input
    String deadlineValue = "";
    if (isEdit && quiz.getDeadline() != null) {
        deadlineValue = quiz.getDeadline().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
    }

    // Get current target tags as a Set for multi-select
    HashSet<String> currentTargetTags = new HashSet<>();
    if (isEdit && quiz.getTargetTag() != null && !quiz.getTargetTag().isEmpty() && !"ALL".equals(quiz.getTargetTag())) {
        String[] tagArray = quiz.getTargetTag().split(",");
        for (String tag : tagArray) {
            currentTargetTags.add(tag.trim());
        }
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Buat" %> Quiz - Examora</title>
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
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0"><%= isEdit ? "Edit" : "Buat" %> Quiz</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="../AdminServlet?action=dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="../QuizServlet?action=list">Quiz</a></li>
                        <li class="breadcrumb-item active"><%= isEdit ? "Edit" : "Buat" %></li>
                    </ol>
                </nav>
            </div>
        </div>

        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle me-2"></i><%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-body">
                        <form action="../QuizServlet" method="post">
                        <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
                            <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
                            <% if (isEdit) { %>
                            <input type="hidden" name="id" value="<%= quiz.getId() %>">
                            <% } %>

                            <div class="mb-3">
                                <label for="title" class="form-label">Judul Quiz <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="title" name="title" required
                                       value="<%= isEdit ? quiz.getTitle() : "" %>"
                                       placeholder="Contoh: Ujian Tengah Semester Matematika">
                            </div>

                            <div class="mb-3">
                                <label for="description" class="form-label">Deskripsi</label>
                                <textarea class="form-control" id="description" name="description" rows="3"
                                          placeholder="Deskripsi singkat tentang quiz ini"><%= isEdit && quiz.getDescription() != null ? quiz.getDescription() : "" %></textarea>
                            </div>

                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="duration" class="form-label">Durasi (menit) <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="duration" name="duration"
                                               min="1" max="180" required
                                               value="<%= isEdit ? quiz.getDuration() : 30 %>">
                                        <div class="form-text">Durasi maksimal 180 menit (3 jam)</div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label for="deadline" class="form-label">Deadline (WIB) <span class="text-muted">(opsional)</span></label>
                                        <input type="datetime-local" class="form-control" id="deadline" name="deadline"
                                               value="<%= deadlineValue %>">
                                        <div class="form-text">Format waktu WIB (Jakarta). Kosongkan jika tidak ada deadline</div>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Target Peserta <span class="text-muted">(opsional)</span></label>
                                <div class="border rounded p-3" style="max-height: 200px; overflow-y: auto;">
                                    <div class="form-check mb-2">
                                        <input class="form-check-input" type="checkbox" id="tagAll" name="targetTags" value="ALL"
                                               <%= currentTargetTags.isEmpty() ? "checked" : "" %>>
                                        <label class="form-check-label" for="tagAll">
                                            <strong>-- Semua Peserta --</strong>
                                        </label>
                                    </div>
                                    <hr class="my-2">
                                    <% if (tags != null && !tags.isEmpty()) {
                                        for (String tag : tags) { %>
                                    <div class="form-check">
                                        <input class="form-check-input target-tag-checkbox" type="checkbox" id="tag<%= tag.replace("-", "") %>" name="targetTags" value="<%= tag %>"
                                               <%= currentTargetTags.contains(tag) ? "checked" : "" %>>
                                        <label class="form-check-label" for="tag<%= tag.replace("-", "") %>">
                                            <%= tag %>
                                        </label>
                                    </div>
                                    <% }
                                    } else { %>
                                    <div class="text-muted small">Belum ada tag tersedia</div>
                                    <% } %>
                                </div>
                                <div class="form-text">Pilih satu atau beberapa tag untuk membatasi quiz hanya untuk peserta tertentu. Pilih "Semua Peserta" untuk semua user</div>
                            </div>

                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check-lg me-2"></i><%= isEdit ? "Update" : "Simpan" %>
                                </button>
                                <a href="../QuizServlet?action=list" class="btn btn-outline-secondary">
                                    <i class="bi bi-x-lg me-2"></i>Batal
                                </a>
                                <% if (!isEdit) { %>
                                <button type="submit" name="addQuestions" value="true" class="btn btn-success">
                                    <i class="bi bi-list-check me-2"></i>Simpan & Tambah Soal
                                </button>
                                <% } %>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="card">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-lightbulb me-2"></i>Panduan</h6>
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled mb-0">
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Buat judul yang jelas dan deskriptif</li>
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Tentukan durasi yang sesuai dengan jumlah soal</li>
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Set deadline agar peserta tahu batas waktu</li>
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Setelah membuat quiz, tambahkan soal-soal</li>
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Publish quiz setelah semua soal selesai</li>
                        </ul>
                    </div>
                </div>

                <div class="card mt-3">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-clock me-2"></i>Info Deadline</h6>
                    </div>
                    <div class="card-body">
                        <p class="small text-muted mb-0">
                            Deadline adalah batas waktu terakhir peserta dapat mengerjakan quiz.
                            Setelah deadline, quiz tidak akan muncul di daftar quiz peserta.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Handle checkbox behavior for target tags
        document.addEventListener('DOMContentLoaded', function() {
            const tagAllCheckbox = document.getElementById('tagAll');
            const tagCheckboxes = document.querySelectorAll('.target-tag-checkbox');

            // When "Semua Peserta" is checked, uncheck all other tags
            tagAllCheckbox.addEventListener('change', function() {
                if (this.checked) {
                    tagCheckboxes.forEach(function(cb) {
                        cb.checked = false;
                    });
                }
            });

            // When any specific tag is checked, uncheck "Semua Peserta"
            tagCheckboxes.forEach(function(cb) {
                cb.addEventListener('change', function() {
                    if (this.checked) {
                        tagAllCheckbox.checked = false;
                    }
                    // If no specific tag is selected, check "Semua Peserta"
                    const anyChecked = Array.from(tagCheckboxes).some(function(c) {
                        return c.checked;
                    });
                    if (!anyChecked) {
                        tagAllCheckbox.checked = true;
                    }
                });
            });
        });
    </script>
</body>
</html>
