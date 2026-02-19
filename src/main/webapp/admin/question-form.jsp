<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Quiz" %>
<%@ page import="com.examora.model.Question" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    Quiz quiz = (Quiz) request.getAttribute("quiz");
    Question question = (Question) request.getAttribute("question");
    boolean isEdit = question != null && question.getId() != null;
    String error = (String) request.getAttribute("error");
    String successParam = request.getParameter("success");

    if (quiz == null) {
        response.sendRedirect("../QuizServlet?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Tambah" %> Soal - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <!-- Sidebar -->
    <nav class="sidebar">
        <a href="../index.jsp" class="sidebar-brand">
            <i class="bi bi-journal-check me-2"></i>Examora
        </a>
        <hr class="sidebar-divider bg-white opacity-25">
        <ul class="sidebar-menu">
            <li><a href="../AdminServlet?action=dashboard"><i class="bi bi-speedometer2"></i>Dashboard</a></li>
            <li><a href="../QuizServlet?action=list" class="active"><i class="bi bi-journal-text"></i>Kelola Quiz</a></li>
            <li><a href="../ArenaServlet?action=list"><i class="bi bi-trophy"></i>Kelola Arena</a></li>
            <li><a href="../AdminServlet?action=users"><i class="bi bi-people"></i>Kelola User</a></li>
            <li><a href="../AttendanceServlet?action=list"><i class="bi bi-check2-square"></i>Absensi</a></li>
            <li><a href="../AdminServlet?action=statistics"><i class="bi bi-graph-up"></i>Statistik</a></li>
            <li><a href="../SettingsServlet"><i class="bi bi-gear"></i>Pengaturan</a></li>
            <li class="mt-5"><a href="../LogoutServlet"><i class="bi bi-box-arrow-left"></i>Logout</a></li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0"><%= isEdit ? "Edit" : "Tambah" %> Soal</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="dashboard.jsp">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="../QuizServlet?action=list">Quiz</a></li>
                        <li class="breadcrumb-item"><a href="../QuestionServlet?action=list&quizId=<%= quiz.getId() %>"><%= quiz.getTitle() %></a></li>
                        <li class="breadcrumb-item active"><%= isEdit ? "Edit" : "Tambah" %> Soal</li>
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

        <% if ("true".equals(successParam)) { %>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle me-2"></i>Pertanyaan berhasil ditambahkan. Silakan tambah pertanyaan berikutnya.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <div class="row">
            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-question-circle me-2"></i><%= quiz.getTitle() %></h6>
                    </div>
                    <div class="card-body">
                        <form action="../QuestionServlet" method="post" id="questionForm">
                            <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
                            <input type="hidden" name="quizId" value="<%= quiz.getId() %>">
                            <% if (isEdit) { %>
                            <input type="hidden" name="id" value="<%= question.getId() %>">
                            <% } %>

                            <div class="mb-3">
                                <label for="questionText" class="form-label">Pertanyaan <span class="text-danger">*</span></label>
                                <textarea class="form-control" id="questionText" name="questionText" rows="3" required
                                          placeholder="Tulis pertanyaan di sini..."><%= isEdit ? question.getQuestionText() : "" %></textarea>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="optionA" class="form-label">Opsi A <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="optionA" name="optionA" required
                                           value="<%= isEdit ? question.getOptionA() : "" %>" placeholder="Jawaban A">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="optionB" class="form-label">Opsi B <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="optionB" name="optionB" required
                                           value="<%= isEdit ? question.getOptionB() : "" %>" placeholder="Jawaban B">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="optionC" class="form-label">Opsi C <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="optionC" name="optionC" required
                                           value="<%= isEdit ? question.getOptionC() : "" %>" placeholder="Jawaban C">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="optionD" class="form-label">Opsi D <span class="text-danger">*</span></label>
                                    <input type="text" class="form-control" id="optionD" name="optionD" required
                                           value="<%= isEdit ? question.getOptionD() : "" %>" placeholder="Jawaban D">
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label">Jawaban Benar <span class="text-danger">*</span></label>
                                <div class="d-flex gap-3">
                                    <% String[] options = {"A", "B", "C", "D"};
                                       for (String opt : options) { %>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="correctAnswer"
                                               id="answer<%= opt %>" value="<%= opt %>"
                                               <%= isEdit && opt.equals(question.getCorrectAnswer()) ? "checked" : "" %>
                                               <%= !isEdit && opt.equals("A") ? "checked" : "" %> required>
                                        <label class="form-check-label" for="answer<%= opt %>"><%= opt %></label>
                                    </div>
                                    <% } %>
                                </div>
                            </div>

                            <div class="d-flex gap-2">
                                <input type="hidden" name="saveAndAdd" id="saveAndAdd" value="">
                                <button type="submit" class="btn btn-primary" onclick="document.getElementById('saveAndAdd').value='';">
                                    <i class="bi bi-check-lg me-2"></i><%= isEdit ? "Update" : "Simpan" %>
                                </button>
                                <% if (!isEdit) { %>
                                <button type="submit" class="btn btn-success" onclick="document.getElementById('saveAndAdd').value='true';">
                                    <i class="bi bi-plus-lg me-2"></i>Simpan & Tambah Lagi
                                </button>
                                <% } %>
                                <a href="../QuestionServlet?action=list&quizId=<%= quiz.getId() %>" class="btn btn-outline-secondary">
                                    <i class="bi bi-x-lg me-2"></i>Batal
                                </a>
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
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Tulis pertanyaan yang jelas dan tidak ambigu</li>
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Pastikan semua opsi jawaban terisi</li>
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Hanya ada satu jawaban yang benar</li>
                            <li class="mb-2"><i class="bi bi-check text-success me-2"></i>Hindari jawaban yang terlalu mirip</li>
                        </ul>
                    </div>
                </div>

                <div class="card mt-3">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-preview me-2"></i>Preview</h6>
                    </div>
                    <div class="card-body">
                        <div id="preview" class="border rounded p-3" style="min-height: 100px;">
                            <p id="previewQuestion" class="fw-bold mb-3 text-muted">Preview pertanyaan...</p>
                            <div id="previewOptions"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Live preview
        function updatePreview() {
            const question = document.getElementById('questionText').value;
            const optA = document.getElementById('optionA').value;
            const optB = document.getElementById('optionB').value;
            const optC = document.getElementById('optionC').value;
            const optD = document.getElementById('optionD').value;
            const correct = document.querySelector('input[name="correctAnswer"]:checked');

            document.getElementById('previewQuestion').textContent = question || 'Preview pertanyaan...';
            document.getElementById('previewQuestion').classList.toggle('text-muted', !question);

            let html = '';
            const options = [
                {label: 'A', value: optA},
                {label: 'B', value: optB},
                {label: 'C', value: optC},
                {label: 'D', value: optD}
            ];

            options.forEach(opt => {
                const isCorrect = correct && correct.value === opt.label;
                html += `<div class="mb-1 ${isCorrect ? 'text-success fw-bold' : ''}">${opt.label}. ${opt.value || '...'}</div>`;
            });

            document.getElementById('previewOptions').innerHTML = html;
        }

        document.querySelectorAll('input, textarea').forEach(el => {
            el.addEventListener('input', updatePreview);
        });
        document.querySelectorAll('input[type="radio"]').forEach(el => {
            el.addEventListener('change', updatePreview);
        });

        // Initial preview
        updatePreview();
    </script>
</body>
</html>
