<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Quiz" %>
<%@ page import="com.examora.model.Question" %>
<%@ page import="com.examora.model.QuestionCategory" %>
<%@ page import="com.examora.service.QuestionBankService" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    Quiz quiz = (Quiz) request.getAttribute("quiz");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    // Get bank questions for selection modal
    List<Question> bankQuestions = null;
    List<QuestionCategory> categories = null;
    try {
        QuestionBankService qbs = new QuestionBankService();
        bankQuestions = qbs.getAllBankQuestions();
        categories = qbs.getAllCategories();
    } catch (Exception e) {
        // Ignore
    }

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
    <title>Kelola Soal - <%= quiz.getTitle() %> - Examora</title>
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
                <h1 class="h3 mb-0">Kelola Soal</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="dashboard.jsp">Dashboard</a></li>
                        <li class="breadcrumb-item"><a href="../QuizServlet?action=list">Quiz</a></li>
                        <li class="breadcrumb-item active"><%= quiz.getTitle() %></li>
                    </ol>
                </nav>
            </div>
            <div class="d-flex gap-2">
                <a href="../QuestionServlet?action=create&quizId=<%= quiz.getId() %>" class="btn btn-primary">
                    <i class="bi bi-plus-lg me-2"></i>Tambah Soal Baru
                </a>
                <% if (bankQuestions != null && !bankQuestions.isEmpty()) { %>
                <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#bankModal">
                    <i class="bi bi-collection me-2"></i>Dari Bank Soal
                </button>
                <% } %>
                <a href="../QuizServlet?action=list" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>Kembali
                </a>
            </div>
        </div>

        <!-- Quiz Info -->
        <div class="card mb-4">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <h5><%= quiz.getTitle() %></h5>
                        <p class="text-muted mb-0"><%= quiz.getDescription() %></p>
                    </div>
                    <div class="col-md-3">
                        <strong>Durasi:</strong> <%= quiz.getDuration() %> menit
                    </div>
                    <div class="col-md-3">
                        <strong>Status:</strong>
                        <% if (quiz.getIsActive()) { %>
                        <span class="badge bg-success">Published</span>
                        <% } else { %>
                        <span class="badge bg-secondary">Draft</span>
                        <% } %>
                    </div>
                </div>
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
            <div class="card-header d-flex justify-content-between align-items-center">
                <h6 class="mb-0"><i class="bi bi-list-check me-2"></i>Daftar Soal (<%= questions != null ? questions.size() : 0 %>)</h6>
            </div>
            <div class="card-body">
                <% if (questions != null && !questions.isEmpty()) { %>
                    <% for (int i = 0; i < questions.size(); i++) {
                        Question q = questions.get(i);
                    %>
                    <div class="card mb-3 border">
                        <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                            <span class="badge bg-primary me-2"><%= i + 1 %></span>
                            <span class="flex-grow-1">Soal #<%= i + 1 %></span>
                            <div class="btn-group btn-group-sm">
                                <a href="../QuestionServlet?action=edit&quizId=<%= quiz.getId() %>&id=<%= q.getId() %>"
                                   class="btn btn-outline-primary" title="Edit">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <a href="../QuestionServlet?action=delete&quizId=<%= quiz.getId() %>&id=<%= q.getId() %>"
                                   class="btn btn-outline-danger" title="Hapus"
                                   onclick="return confirm('Hapus soal ini?')">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </div>
                        </div>
                        <div class="card-body">
                            <p class="fw-bold mb-3"><%= q.getQuestionText() %></p>
                            <div class="row">
                                <div class="col-md-6 mb-2">
                                    <div class="p-2 border rounded <%= "A".equals(q.getCorrectAnswer()) ? "bg-success bg-opacity-10 border-success" : "" %>">
                                        <strong>A.</strong> <%= q.getOptionA() %>
                                        <% if ("A".equals(q.getCorrectAnswer())) { %>
                                        <i class="bi bi-check-circle-fill text-success ms-2"></i>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-2">
                                    <div class="p-2 border rounded <%= "B".equals(q.getCorrectAnswer()) ? "bg-success bg-opacity-10 border-success" : "" %>">
                                        <strong>B.</strong> <%= q.getOptionB() %>
                                        <% if ("B".equals(q.getCorrectAnswer())) { %>
                                        <i class="bi bi-check-circle-fill text-success ms-2"></i>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-2">
                                    <div class="p-2 border rounded <%= "C".equals(q.getCorrectAnswer()) ? "bg-success bg-opacity-10 border-success" : "" %>">
                                        <strong>C.</strong> <%= q.getOptionC() %>
                                        <% if ("C".equals(q.getCorrectAnswer())) { %>
                                        <i class="bi bi-check-circle-fill text-success ms-2"></i>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-2">
                                    <div class="p-2 border rounded <%= "D".equals(q.getCorrectAnswer()) ? "bg-success bg-opacity-10 border-success" : "" %>">
                                        <strong>D.</strong> <%= q.getOptionD() %>
                                        <% if ("D".equals(q.getCorrectAnswer())) { %>
                                        <i class="bi bi-check-circle-fill text-success ms-2"></i>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                <% } else { %>
                <div class="text-center py-5">
                    <i class="bi bi-question-circle display-1 text-muted mb-3 d-block"></i>
                    <h4 class="text-muted">Belum ada soal</h4>
                    <p class="text-muted">Mulai dengan menambahkan soal pertama</p>
                    <a href="../QuestionServlet?action=create&quizId=<%= quiz.getId() %>" class="btn btn-primary">
                        <i class="bi bi-plus-lg me-2"></i>Tambah Soal
                    </a>
                </div>
                <% } %>
            </div>
        </div>

        <% if (questions != null && !questions.isEmpty() && !quiz.getIsActive()) { %>
        <div class="text-center mt-4">
            <a href="../QuizServlet?action=publish&id=<%= quiz.getId() %>" class="btn btn-success btn-lg"
               onclick="return confirm('Publish quiz ini? Peserta akan dapat mengerjakan quiz.')">
                <i class="bi bi-play-circle me-2"></i>Publish Quiz
            </a>
        </div>
        <% } %>
    </div>

    <!-- Modal: Add from Bank -->
    <div class="modal fade" id="bankModal" tabindex="-1">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-collection me-2"></i>Pilih dari Bank Soal</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="bankForm" action="../QuestionBankServlet?action=addToQuiz" method="post">
                        <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>">
                        <input type="hidden" name="quizId" value="<%= quiz.getId() %>">

                        <% if (categories != null && !categories.isEmpty()) { %>
                        <div class="mb-3">
                            <label class="form-label">Filter Kategori:</label>
                            <select class="form-select" id="categoryFilter" onchange="filterQuestions()">
                                <option value="">Semua Kategori</option>
                                <% for (QuestionCategory cat : categories) { %>
                                <option value="cat-<%= cat.getId() %>"><%= cat.getName() %></option>
                                <% } %>
                            </select>
                        </div>
                        <% } %>

                        <div class="table-responsive" style="max-height: 400px;">
                            <table class="table table-hover table-sm">
                                <thead class="sticky-top bg-white">
                                    <tr>
                                        <th width="40"><input type="checkbox" id="selectAll" onchange="toggleAll()"></th>
                                        <th>Soal</th>
                                        <th>Kategori</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (bankQuestions != null) {
                                        for (Question q : bankQuestions) { %>
                                    <tr class="bank-question" data-category="cat-<%= q.getCategoryId() != null ? q.getCategoryId() : "" %>">
                                        <td>
                                            <input type="checkbox" name="questionIds" value="<%= q.getId() %>" class="q-checkbox">
                                        </td>
                                        <td>
                                            <small><%= q.getQuestionText().length() > 100 ? q.getQuestionText().substring(0, 100) + "..." : q.getQuestionText() %></small>
                                        </td>
                                        <td>
                                            <small class="text-muted"><%= q.getCategoryName() != null ? q.getCategoryName() : "-" %></small>
                                        </td>
                                    </tr>
                                    <% }
                                    } %>
                                </tbody>
                            </table>
                        </div>

                        <div class="mt-3">
                            <span class="text-muted"><span id="selectedCount">0</span> soal dipilih</span>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                    <button type="button" class="btn btn-primary" onclick="document.getElementById('bankForm').submit()">
                        <i class="bi bi-plus-lg me-1"></i>Tambah ke Quiz
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleAll() {
            const checkboxes = document.querySelectorAll('.q-checkbox');
            const selectAll = document.getElementById('selectAll');
            checkboxes.forEach(cb => {
                const row = cb.closest('tr');
                if (row.style.display !== 'none') {
                    cb.checked = selectAll.checked;
                }
            });
            updateCount();
        }

        function filterQuestions() {
            const filter = document.getElementById('categoryFilter').value;
            const rows = document.querySelectorAll('.bank-question');
            rows.forEach(row => {
                if (!filter || row.dataset.category === filter) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        function updateCount() {
            const checked = document.querySelectorAll('.q-checkbox:checked').length;
            document.getElementById('selectedCount').textContent = checked;
        }

        document.querySelectorAll('.q-checkbox').forEach(cb => {
            cb.addEventListener('change', updateCount);
        });
    </script>
</body>
</html>
