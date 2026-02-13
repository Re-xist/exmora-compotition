<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.Quiz" %>
<%@ page import="com.examora.model.Submission" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    Map<String, Object> statistics = (Map<String, Object>) request.getAttribute("statistics");
    List<Map<String, Object>> submissions = (List<Map<String, Object>>) request.getAttribute("submissions");
    Integer selectedQuizId = (Integer) request.getAttribute("selectedQuizId");
    String error = (String) request.getAttribute("error");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Statistik - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .user-detail-modal .modal-body {
            max-height: 70vh;
            overflow-y: auto;
        }
        .question-item {
            border-left: 4px solid #dee2e6;
            padding-left: 15px;
            margin-bottom: 20px;
        }
        .question-item.correct {
            border-left-color: #198754;
            background-color: rgba(25, 135, 84, 0.05);
        }
        .question-item.wrong {
            border-left-color: #dc3545;
            background-color: rgba(220, 53, 69, 0.05);
        }
        .question-item.unanswered {
            border-left-color: #ffc107;
            background-color: rgba(255, 193, 7, 0.05);
        }
        .option-item {
            padding: 8px 12px;
            border-radius: 5px;
            margin-bottom: 5px;
        }
        .option-item.selected {
            background-color: rgba(13, 110, 253, 0.1);
            border: 1px solid rgba(13, 110, 253, 0.3);
        }
        .option-item.correct-answer {
            background-color: rgba(25, 135, 84, 0.1);
            border: 1px solid rgba(25, 135, 84, 0.3);
        }
        .option-item.wrong-answer {
            background-color: rgba(220, 53, 69, 0.1);
            border: 1px solid rgba(220, 53, 69, 0.3);
        }
        #userDetailContent {
            background: white;
            padding: 20px;
        }
        @media print {
            .no-print { display: none !important; }
        }
    </style>
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
            <li><a href="../QuizServlet?action=list"><i class="bi bi-journal-text"></i>Kelola Quiz</a></li>
            <li><a href="../AdminServlet?action=users"><i class="bi bi-people"></i>Kelola User</a></li>
            <li><a href="../AdminServlet?action=statistics" class="active"><i class="bi bi-graph-up"></i>Statistik</a></li>
            <li><a href="../SettingsServlet"><i class="bi bi-gear"></i>Pengaturan</a></li>
            <li class="mt-5"><a href="../LogoutServlet"><i class="bi bi-box-arrow-left"></i>Logout</a></li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Statistik Quiz</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="dashboard.jsp">Dashboard</a></li>
                        <li class="breadcrumb-item active">Statistik</li>
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

        <!-- Quiz Selector -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="../AdminServlet" class="row g-3 align-items-center">
                    <input type="hidden" name="action" value="statistics">
                    <div class="col-auto">
                        <label class="form-label mb-0"><i class="bi bi-journal-text me-2"></i>Pilih Quiz:</label>
                    </div>
                    <div class="col-md-4">
                        <select name="quizId" class="form-select" onchange="this.form.submit()">
                            <option value="">-- Pilih Quiz --</option>
                            <% if (quizzes != null) {
                                for (Quiz quiz : quizzes) { %>
                            <option value="<%= quiz.getId() %>"
                                    <%= selectedQuizId != null && selectedQuizId.equals(quiz.getId()) ? "selected" : "" %>>
                                <%= quiz.getTitle() %>
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>
                </form>
            </div>
        </div>

        <% if (statistics != null) { %>
        <!-- Statistics Overview -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card stat-card bg-primary text-white h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Total Peserta</p>
                                <h2 class="stat-value mb-0"><%= statistics.get("totalSubmissions") != null ? statistics.get("totalSubmissions") : 0 %></h2>
                            </div>
                            <i class="bi bi-people stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-success text-white h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Rata-rata Nilai</p>
                                <h2 class="stat-value mb-0"><%= statistics.get("averageScore") != null ?
                                    String.format("%.1f", statistics.get("averageScore")) : "0" %></h2>
                            </div>
                            <i class="bi bi-graph-up stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-info text-white h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Nilai Tertinggi</p>
                                <h2 class="stat-value mb-0"><%= statistics.get("highestScore") != null ?
                                    String.format("%.0f", statistics.get("highestScore")) : "0" %></h2>
                            </div>
                            <i class="bi bi-trophy stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-warning text-white h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Nilai Terendah</p>
                                <h2 class="stat-value mb-0"><%= statistics.get("lowestScore") != null ?
                                    String.format("%.0f", statistics.get("lowestScore")) : "0" %></h2>
                            </div>
                            <i class="bi bi-arrow-down stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Row -->
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-bar-chart me-2"></i>Distribusi Nilai</h6>
                    </div>
                    <div class="card-body">
                        <canvas id="scoreDistributionChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-pie-chart me-2"></i>Kelulusan</h6>
                    </div>
                    <div class="card-body">
                        <canvas id="passRateChart"></canvas>
                    </div>
                </div>
            </div>
        </div>

        <!-- Score Distribution Table -->
        <div class="card mb-4">
            <div class="card-header">
                <h6 class="mb-0"><i class="bi bi-table me-2"></i>Distribusi Nilai Detail</h6>
            </div>
            <div class="card-body">
                <div class="row text-center">
                    <div class="col">
                        <div class="p-3 border rounded">
                            <h4 class="text-danger"><%= statistics.get("scoreRange0_40") != null ? statistics.get("scoreRange0_40") : 0 %></h4>
                            <small class="text-muted">0 - 40</small>
                            <br><span class="badge bg-danger">Sangat Kurang</span>
                        </div>
                    </div>
                    <div class="col">
                        <div class="p-3 border rounded">
                            <h4 class="text-warning"><%= statistics.get("scoreRange41_60") != null ? statistics.get("scoreRange41_60") : 0 %></h4>
                            <small class="text-muted">41 - 60</small>
                            <br><span class="badge bg-warning">Kurang</span>
                        </div>
                    </div>
                    <div class="col">
                        <div class="p-3 border rounded">
                            <h4 class="text-info"><%= statistics.get("scoreRange61_75") != null ? statistics.get("scoreRange61_75") : 0 %></h4>
                            <small class="text-muted">61 - 75</small>
                            <br><span class="badge bg-info">Cukup</span>
                        </div>
                    </div>
                    <div class="col">
                        <div class="p-3 border rounded">
                            <h4 class="text-primary"><%= statistics.get("scoreRange76_85") != null ? statistics.get("scoreRange76_85") : 0 %></h4>
                            <small class="text-muted">76 - 85</small>
                            <br><span class="badge bg-primary">Baik</span>
                        </div>
                    </div>
                    <div class="col">
                        <div class="p-3 border rounded">
                            <h4 class="text-success"><%= statistics.get("scoreRange86_100") != null ? statistics.get("scoreRange86_100") : 0 %></h4>
                            <small class="text-muted">86 - 100</small>
                            <br><span class="badge bg-success">Sangat Baik</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Additional Stats -->
        <div class="row mb-4">
            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-clock-history me-2"></i>Statistik Waktu</h6>
                    </div>
                    <div class="card-body">
                        <table class="table table-borderless mb-0">
                            <tr>
                                <td class="text-muted">Rata-rata Waktu Pengerjaan:</td>
                                <td class="text-end fw-bold">
                                    <%= statistics.get("averageTimeSpent") != null ?
                                        statistics.get("averageTimeSpent") + " detik" : "-" %>
                                </td>
                            </tr>
                            <tr>
                                <td class="text-muted">Waktu Tercepat:</td>
                                <td class="text-end fw-bold">
                                    <%= statistics.get("minTimeSpent") != null ?
                                        statistics.get("minTimeSpent") + " detik" : "-" %>
                                </td>
                            </tr>
                            <tr>
                                <td class="text-muted">Waktu Terlama:</td>
                                <td class="text-end fw-bold">
                                    <%= statistics.get("maxTimeSpent") != null ?
                                        statistics.get("maxTimeSpent") + " detik" : "-" %>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card h-100">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="bi bi-percent me-2"></i>Ringkasan</h6>
                    </div>
                    <div class="card-body">
                        <table class="table table-borderless mb-0">
                            <tr>
                                <td class="text-muted">Tingkat Kelulusan (>=60):</td>
                                <td class="text-end fw-bold">
                                    <% double passRate = statistics.get("passRate") != null ?
                                        (Double) statistics.get("passRate") : 0; %>
                                    <span class="text-<%= passRate >= 70 ? "success" : passRate >= 50 ? "warning" : "danger" %>">
                                        <%= String.format("%.1f", passRate) %>%
                                    </span>
                                </td>
                            </tr>
                            <tr>
                                <td class="text-muted">Lulus:</td>
                                <td class="text-end fw-bold text-success">
                                    <%= statistics.get("passedCount") != null ? statistics.get("passedCount") : 0 %> peserta
                                </td>
                            </tr>
                            <tr>
                                <td class="text-muted">Tidak Lulus:</td>
                                <td class="text-end fw-bold text-danger">
                                    <%= statistics.get("failedCount") != null ? statistics.get("failedCount") : 0 %> peserta
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Participant List Table -->
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                <h6 class="mb-0"><i class="bi bi-people me-2"></i>Daftar Peserta & Nilai</h6>
                <% if (submissions != null && !submissions.isEmpty()) { %>
                <div class="d-flex gap-2 flex-wrap">
                    <span class="badge bg-secondary" id="totalCount">Total: <%= submissions.size() %> peserta</span>
                    <button class="btn btn-outline-primary btn-sm" onclick="exportAllToPdf()">
                        <i class="bi bi-file-earmark-pdf me-1"></i>Export PDF
                    </button>
                </div>
                <% } %>
            </div>
            <div class="card-body">
                <% if (submissions != null && !submissions.isEmpty()) { %>
                <!-- Search and Filter -->
                <div class="row mb-3 g-2">
                    <div class="col-md-4">
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <input type="text" class="form-control" id="searchInput" placeholder="Cari nama peserta..." onkeyup="filterTable()">
                        </div>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" id="tagFilter" onchange="filterTable()">
                            <option value="">Semua Tag</option>
                            <%
                                // Collect unique tags from submissions
                                java.util.Set<String> uniqueTags = new java.util.TreeSet<>();
                                for (Map<String, Object> sub : submissions) {
                                    String tag = (String) sub.get("userTag");
                                    if (tag != null && !tag.isEmpty()) {
                                        uniqueTags.add(tag);
                                    }
                                }
                                for (String tag : uniqueTags) {
                            %>
                            <option value="<%= tag %>"><%= tag %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" id="scoreFilter" onchange="filterTable()">
                            <option value="">Semua Nilai</option>
                            <option value="pass">Lulus (>= 60)</option>
                            <option value="fail">Tidak Lulus (< 60)</option>
                            <option value="excellent">Sangat Baik (>= 86)</option>
                            <option value="good">Baik (76-85)</option>
                            <option value="fair">Cukup (61-75)</option>
                            <option value="poor">Kurang (< 61)</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <select class="form-select" id="pageSize" onchange="changePageSize()">
                            <option value="25">25 / halaman</option>
                            <option value="50" selected>50 / halaman</option>
                            <option value="100">100 / halaman</option>
                            <option value="all">Semua</option>
                        </select>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover" id="participantsTable">
                        <thead class="table-light">
                            <tr>
                                <th class="text-center" width="50">No</th>
                                <th>Nama Peserta</th>
                                <th>Tag</th>
                                <th class="text-center">Nilai</th>
                                <th class="text-center">Benar</th>
                                <th class="text-center">Salah</th>
                                <th class="text-center">Tidak Dijawab</th>
                                <th class="text-center">Waktu</th>
                                <th class="text-center">Aksi</th>
                            </tr>
                        </thead>
                        <tbody id="participantsBody">
                            <% int no = 1;
                               for (Map<String, Object> sub : submissions) {
                                   Double score = (Double) sub.get("score");
                                   String scoreClass = score >= 86 ? "success" : score >= 76 ? "primary" :
                                                       score >= 61 ? "info" : score >= 41 ? "warning" : "danger";
                                   String userTag = (String) sub.get("userTag");
                            %>
                            <tr data-name="<%= sub.get("userName") != null ? ((String)sub.get("userName")).toLowerCase() : "" %>"
                                data-tag="<%= userTag != null ? userTag : "" %>"
                                data-score="<%= score %>">
                                <td class="text-center"><%= no++ %></td>
                                <td>
                                    <strong><%= sub.get("userName") %></strong>
                                </td>
                                <td>
                                    <% if (userTag != null && !userTag.isEmpty()) { %>
                                    <span class="badge bg-info"><i class="bi bi-tag me-1"></i><%= userTag %></span>
                                    <% } else { %>
                                    <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                                <td class="text-center">
                                    <span class="badge bg-<%= scoreClass %>">
                                        <%= String.format("%.0f", score) %>
                                    </span>
                                </td>
                                <td class="text-center text-success">
                                    <strong><%= sub.get("correctAnswers") %></strong>
                                </td>
                                <td class="text-center text-danger">
                                    <strong><%= sub.get("wrongCount") %></strong>
                                </td>
                                <td class="text-center text-warning">
                                    <strong><%= sub.get("unanswered") %></strong>
                                </td>
                                <td class="text-center">
                                    <%= sub.get("timeSpent") %> detik
                                </td>
                                <td class="text-center">
                                    <button class="btn btn-sm btn-outline-primary"
                                            onclick="loadUserDetail('<%= sub.get("id") %>')"
                                            title="Lihat Detail">
                                        <i class="bi bi-eye"></i> Detail
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <div id="paginationWrapper" class="d-flex justify-content-between align-items-center mt-3">
                    <div class="text-muted small" id="showingInfo"></div>
                    <nav id="paginationNav">
                        <ul class="pagination pagination-sm mb-0" id="paginationList"></ul>
                    </nav>
                </div>

                <% } else { %>
                <div class="text-center py-4 text-muted">
                    <i class="bi bi-inbox display-4 d-block mb-2"></i>
                    Belum ada peserta yang mengerjakan quiz ini
                </div>
                <% } %>
            </div>
        </div>

        <% } else { %>
        <!-- No Quiz Selected -->
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="bi bi-graph-up display-1 text-muted mb-3 d-block"></i>
                <h4 class="text-muted">Pilih Quiz untuk Melihat Statistik</h4>
                <p class="text-muted">Pilih quiz dari dropdown di atas untuk melihat statistik dan distribusi nilai.</p>
            </div>
        </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- User Detail Modal -->
    <div class="modal fade" id="userDetailModal" tabindex="-1">
        <div class="modal-dialog modal-xl">
            <div class="modal-content user-detail-modal">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-person-check me-2"></i>Detail Jawaban Peserta
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="userDetailBody">
                    <div class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer no-print">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Tutup</button>
                    <button type="button" class="btn btn-primary" onclick="exportDetailToPdf()">
                        <i class="bi bi-file-earmark-pdf me-1"></i>Export PDF
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast Notification -->
    <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999;">
        <div id="toastNotification" class="toast align-items-center border-0" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="d-flex">
                <div class="toast-body">
                    <i class="bi me-2" id="toastIcon"></i>
                    <span id="toastMessage"></span>
                </div>
                <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    </div>

    <% if (statistics != null) { %>
    <script>
        // Show toast notification
        function showToast(message, type = 'info') {
            const toastEl = document.getElementById('toastNotification');
            const toastIcon = document.getElementById('toastIcon');
            const toastMessage = document.getElementById('toastMessage');

            // Set icon and color based on type
            const types = {
                success: { icon: 'bi-check-circle-fill', class: 'text-success bg-success bg-opacity-10' },
                danger: { icon: 'bi-x-circle-fill', class: 'text-danger bg-danger bg-opacity-10' },
                warning: { icon: 'bi-exclamation-triangle-fill', class: 'text-warning bg-warning bg-opacity-10' },
                info: { icon: 'bi-info-circle-fill', class: 'text-info bg-info bg-opacity-10' }
            };

            const config = types[type] || types.info;
            toastIcon.className = 'bi ' + config.icon;
            toastMessage.textContent = message;
            toastEl.className = 'toast align-items-center border-0 ' + config.class;

            const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
            toast.show();
        }

        // Score Distribution Chart
        const scoreCtx = document.getElementById('scoreDistributionChart').getContext('2d');
        new Chart(scoreCtx, {
            type: 'bar',
            data: {
                labels: ['0-40', '41-60', '61-75', '76-85', '86-100'],
                datasets: [{
                    label: 'Jumlah Peserta',
                    data: [
                        <%= statistics.get("scoreRange0_40") != null ? statistics.get("scoreRange0_40") : 0 %>,
                        <%= statistics.get("scoreRange41_60") != null ? statistics.get("scoreRange41_60") : 0 %>,
                        <%= statistics.get("scoreRange61_75") != null ? statistics.get("scoreRange61_75") : 0 %>,
                        <%= statistics.get("scoreRange76_85") != null ? statistics.get("scoreRange76_85") : 0 %>,
                        <%= statistics.get("scoreRange86_100") != null ? statistics.get("scoreRange86_100") : 0 %>
                    ],
                    backgroundColor: [
                        'rgba(239, 71, 111, 0.8)',
                        'rgba(255, 209, 102, 0.8)',
                        'rgba(17, 138, 178, 0.8)',
                        'rgba(67, 97, 238, 0.8)',
                        'rgba(6, 214, 160, 0.8)'
                    ],
                    borderColor: [
                        'rgba(239, 71, 111, 1)',
                        'rgba(255, 209, 102, 1)',
                        'rgba(17, 138, 178, 1)',
                        'rgba(67, 97, 238, 1)',
                        'rgba(6, 214, 160, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1
                        }
                    }
                }
            }
        });

        // Pass Rate Chart
        const passCtx = document.getElementById('passRateChart').getContext('2d');
        new Chart(passCtx, {
            type: 'doughnut',
            data: {
                labels: ['Lulus (>=60)', 'Tidak Lulus (<60)'],
                datasets: [{
                    data: [
                        <%= statistics.get("passedCount") != null ? statistics.get("passedCount") : 0 %>,
                        <%= statistics.get("failedCount") != null ? statistics.get("failedCount") : 0 %>
                    ],
                    backgroundColor: [
                        'rgba(6, 214, 160, 0.8)',
                        'rgba(239, 71, 111, 0.8)'
                    ],
                    borderColor: [
                        'rgba(6, 214, 160, 1)',
                        'rgba(239, 71, 111, 1)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });

        // Load user detail via AJAX
        function loadUserDetail(submissionId) {
            console.log('Loading user detail for submission:', submissionId);

            if (!submissionId) {
                showToast('Submission ID tidak valid', 'warning');
                return;
            }

            const modal = new bootstrap.Modal(document.getElementById('userDetailModal'));
            document.getElementById('userDetailBody').innerHTML = `
                <div class="text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="text-muted mt-3">Memuat data...</p>
                </div>
            `;
            modal.show();

            // Fetch user detail
            fetch(`../AdminServlet?action=userDetail&submissionId=${submissionId}`)
                .then(response => {
                    if (!response.ok) throw new Error('Failed to load');
                    return response.text();
                })
                .then(html => {
                    document.getElementById('userDetailBody').innerHTML = html;
                    // Initialize chart if data exists
                    initUserChart();
                })
                .catch(error => {
                    document.getElementById('userDetailBody').innerHTML = `
                        <div id="userDetailContent">
                            <div class="text-center py-5">
                                <div class="mb-4">
                                    <i class="bi bi-exclamation-triangle display-1 text-danger"></i>
                                </div>
                                <h4 class="text-muted mb-3">Gagal Memuat Data</h4>
                                <p class="text-muted">${error.message}</p>
                                <button class="btn btn-outline-primary btn-sm" onclick="loadUserDetail('${submissionId}')">
                                    <i class="bi bi-arrow-clockwise me-1"></i>Coba Lagi
                                </button>
                            </div>
                        </div>
                    `;
                });
        }

        // Initialize user performance chart
        function initUserChart() {
            const chartCanvas = document.getElementById('userPerformanceChart');
            if (!chartCanvas) return;

            const correct = parseInt(chartCanvas.dataset.correct || 0);
            const wrong = parseInt(chartCanvas.dataset.wrong || 0);
            const unanswered = parseInt(chartCanvas.dataset.unanswered || 0);

            new Chart(chartCanvas.getContext('2d'), {
                type: 'radar',
                data: {
                    labels: ['Benar', 'Salah', 'Tidak Dijawab'],
                    datasets: [{
                        label: 'Jumlah',
                        data: [correct, wrong, unanswered],
                        backgroundColor: [
                            'rgba(25, 135, 84, 0.3)',
                            'rgba(220, 53, 69, 0.3)',
                            'rgba(255, 193, 7, 0.3)'
                        ],
                        borderColor: [
                            'rgba(25, 135, 84, 1)',
                            'rgba(220, 53, 69, 1)',
                            'rgba(255, 193, 7, 1)'
                        ],
                        borderWidth: 2,
                        pointBackgroundColor: [
                            'rgba(25, 135, 84, 1)',
                            'rgba(220, 53, 69, 1)',
                            'rgba(255, 193, 7, 1)'
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        r: {
                            beginAtZero: true,
                            ticks: {
                                stepSize: 1
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            display: false
                        }
                    }
                }
            });
        }

        // Export detail to PDF
        function exportDetailToPdf() {
            const element = document.getElementById('userDetailContent');
            if (!element) {
                alert('Konten tidak ditemukan');
                return;
            }

            const userName = element.dataset.userName || 'peserta';
            const quizTitle = element.dataset.quizTitle || 'quiz';

            const opt = {
                margin: 10,
                filename: `hasil_${quizTitle}_${userName}.pdf`,
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2 },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
            };

            // Hide buttons before export
            document.querySelectorAll('.no-print').forEach(el => el.style.display = 'none');

            html2pdf().set(opt).from(element).save().then(() => {
                // Show buttons after export
                document.querySelectorAll('.no-print').forEach(el => el.style.display = '');
            });
        }

        // Export all participants to PDF
        function exportAllToPdf() {
            const table = document.getElementById('participantsTable');
            if (!table) {
                showToast('Tabel tidak ditemukan', 'warning');
                return;
            }

            const wrapper = document.createElement('div');
            wrapper.innerHTML = `
                <div style="padding: 20px; font-family: Arial, sans-serif;">
                    <h2 style="text-align: center; margin-bottom: 20px;">Daftar Peserta & Nilai</h2>
                    <p style="text-align: center; margin-bottom: 20px;">Quiz: <%= quizzes != null ? quizzes.stream().filter(q -> selectedQuizId != null && q.getId().equals(selectedQuizId)).findFirst().map(q -> q.getTitle()).orElse("") : "" %></p>
                    ${table.outerHTML}
                </div>
            `;

            const opt = {
                margin: 10,
                filename: 'daftar_peserta_<%= selectedQuizId != null ? selectedQuizId : "" %>.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2 },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'landscape' }
            };

            html2pdf().set(opt).from(wrapper).save();
        }

        // Filter and Pagination
        let currentPage = 1;
        let filteredRows = [];

        function filterTable() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const tagFilter = document.getElementById('tagFilter').value;
            const scoreFilter = document.getElementById('scoreFilter').value;
            const tbody = document.getElementById('participantsBody');
            const allRows = Array.from(tbody.getElementsByTagName('tr'));

            filteredRows = allRows.filter(row => {
                const name = row.dataset.name || '';
                const tag = row.dataset.tag || '';
                const score = parseFloat(row.dataset.score) || 0;

                // Search filter
                const matchesSearch = name.includes(searchTerm);

                // Tag filter
                const matchesTag = !tagFilter || tag === tagFilter;

                // Score filter
                let matchesScore = true;
                if (scoreFilter) {
                    switch(scoreFilter) {
                        case 'pass': matchesScore = score >= 60; break;
                        case 'fail': matchesScore = score < 60; break;
                        case 'excellent': matchesScore = score >= 86; break;
                        case 'good': matchesScore = score >= 76 && score < 86; break;
                        case 'fair': matchesScore = score >= 61 && score < 76; break;
                        case 'poor': matchesScore = score < 61; break;
                    }
                }

                return matchesSearch && matchesTag && matchesScore;
            });

            // Update filtered count
            document.getElementById('totalCount').textContent = `Ditemukan: ${filteredRows.length} peserta`;

            currentPage = 1;
            renderTable();
        }

        function renderTable() {
            const tbody = document.getElementById('participantsBody');
            const allRows = Array.from(tbody.getElementsByTagName('tr'));
            const pageSize = document.getElementById('pageSize').value;

            // Hide all rows first
            allRows.forEach(row => row.style.display = 'none');

            // Calculate pagination
            let rowsToShow;
            let totalPages;

            if (pageSize === 'all') {
                rowsToShow = filteredRows.length > 0 ? filteredRows : allRows;
                totalPages = 1;
            } else {
                const size = parseInt(pageSize);
                totalPages = Math.ceil(filteredRows.length / size);
                const startIndex = (currentPage - 1) * size;
                const endIndex = startIndex + size;
                rowsToShow = filteredRows.slice(startIndex, endIndex);
            }

            // Show filtered rows for current page
            rowsToShow.forEach((row, index) => {
                row.style.display = '';
                // Update row number
                const firstCell = row.querySelector('td:first-child');
                if (firstCell && pageSize !== 'all') {
                    const size = parseInt(pageSize);
                    firstCell.textContent = ((currentPage - 1) * size) + index + 1;
                }
            });

            // Update showing info
            const pageSizeVal = pageSize === 'all' ? filteredRows.length : parseInt(pageSize);
            const startItem = filteredRows.length > 0 ? ((currentPage - 1) * pageSizeVal) + 1 : 0;
            const endItem = pageSize === 'all' ? filteredRows.length : Math.min(currentPage * pageSizeVal, filteredRows.length);
            document.getElementById('showingInfo').textContent =
                `Menampilkan ${startItem}-${endItem} dari ${filteredRows.length} peserta`;

            // Render pagination
            renderPagination(totalPages);
        }

        function renderPagination(totalPages) {
            const paginationList = document.getElementById('paginationList');
            paginationList.innerHTML = '';

            if (totalPages <= 1) return;

            // Previous button
            const prevLi = document.createElement('li');
            prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
            prevLi.innerHTML = `<a class="page-link" href="#" onclick="goToPage(${currentPage - 1}); return false;"><i class="bi bi-chevron-left"></i></a>`;
            paginationList.appendChild(prevLi);

            // Page numbers
            const maxVisible = 5;
            let startPage = Math.max(1, currentPage - Math.floor(maxVisible / 2));
            let endPage = Math.min(totalPages, startPage + maxVisible - 1);

            if (endPage - startPage < maxVisible - 1) {
                startPage = Math.max(1, endPage - maxVisible + 1);
            }

            if (startPage > 1) {
                const li = document.createElement('li');
                li.className = 'page-item';
                li.innerHTML = `<a class="page-link" href="#" onclick="goToPage(1); return false;">1</a>`;
                paginationList.appendChild(li);

                if (startPage > 2) {
                    const ellipsis = document.createElement('li');
                    ellipsis.className = 'page-item disabled';
                    ellipsis.innerHTML = `<span class="page-link">...</span>`;
                    paginationList.appendChild(ellipsis);
                }
            }

            for (let i = startPage; i <= endPage; i++) {
                const li = document.createElement('li');
                li.className = `page-item ${i === currentPage ? 'active' : ''}`;
                li.innerHTML = `<a class="page-link" href="#" onclick="goToPage(${i}); return false;">${i}</a>`;
                paginationList.appendChild(li);
            }

            if (endPage < totalPages) {
                if (endPage < totalPages - 1) {
                    const ellipsis = document.createElement('li');
                    ellipsis.className = 'page-item disabled';
                    ellipsis.innerHTML = `<span class="page-link">...</span>`;
                    paginationList.appendChild(ellipsis);
                }

                const li = document.createElement('li');
                li.className = 'page-item';
                li.innerHTML = `<a class="page-link" href="#" onclick="goToPage(${totalPages}); return false;">${totalPages}</a>`;
                paginationList.appendChild(li);
            }

            // Next button
            const nextLi = document.createElement('li');
            nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
            nextLi.innerHTML = `<a class="page-link" href="#" onclick="goToPage(${currentPage + 1}); return false;"><i class="bi bi-chevron-right"></i></a>`;
            paginationList.appendChild(nextLi);
        }

        function goToPage(page) {
            const pageSize = document.getElementById('pageSize').value;
            const size = pageSize === 'all' ? filteredRows.length : parseInt(pageSize);
            const totalPages = Math.ceil(filteredRows.length / size);

            if (page < 1 || page > totalPages) return;

            currentPage = page;
            renderTable();

            // Scroll to table
            document.getElementById('participantsTable').scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        function changePageSize() {
            currentPage = 1;
            filterTable();
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize filtered rows with all rows
            const tbody = document.getElementById('participantsBody');
            if (tbody) {
                filteredRows = Array.from(tbody.getElementsByTagName('tr'));
                renderTable();
            }
        });
    </script>
    <% } %>
</body>
</html>
