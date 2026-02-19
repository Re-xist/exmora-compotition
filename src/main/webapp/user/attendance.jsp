<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.AttendanceSession" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    if (currentUser.isAdmin()) {
        response.sendRedirect("../AdminServlet?action=dashboard");
        return;
    }

    List<AttendanceSession> activeSessions = (List<AttendanceSession>) request.getAttribute("activeSessions");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Absensi - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand fw-bold" href="dashboard.jsp">
                <i class="bi bi-journal-check me-2"></i>Examora
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="../ExamServlet?action=dashboard">
                            <i class="bi bi-house me-1"></i>Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../ExamServlet?action=list">
                            <i class="bi bi-journal-text me-1"></i>Quiz Tersedia
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../ArenaServlet?action=join">
                            <i class="bi bi-trophy me-1"></i>Arena
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="../AttendanceServlet?action=view">
                            <i class="bi bi-check2-square me-1"></i>Absensi
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../ExamServlet?action=history">
                            <i class="bi bi-clock-history me-1"></i>Riwayat
                        </a>
                    </li>
                    <% if (currentUser.getGdriveLink() != null && !currentUser.getGdriveLink().isEmpty()) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#gdriveModal">
                            <i class="bi bi-google me-1"></i>Google Drive
                        </a>
                    </li>
                    <% } %>
                </ul>
                <div class="d-flex align-items-center">
                    <a href="../SettingsServlet" class="text-white text-decoration-none me-3">
                        <i class="bi bi-person-circle me-1"></i><%= currentUser.getName() %>
                    </a>
                    <a href="../LogoutServlet" class="btn btn-outline-light btn-sm">
                        <i class="bi bi-box-arrow-left me-1"></i>Logout
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container py-4">
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col-md-6">
                <h2><i class="bi bi-check2-square me-2"></i>Absensi</h2>
                <p class="text-muted">Masukkan kode sesi untuk melakukan absensi</p>
            </div>
            <div class="col-md-6 text-md-end">
                <a href="../AttendanceServlet?action=history" class="btn btn-outline-primary">
                    <i class="bi bi-clock-history me-2"></i>Riwayat Absensi
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

        <!-- Input Code Card -->
        <div class="row justify-content-center mb-5">
            <div class="col-md-6">
                <div class="card shadow-sm">
                    <div class="card-body text-center py-5">
                        <div class="mb-4">
                            <div class="bg-primary bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center"
                                 style="width: 80px; height: 80px;">
                                <i class="bi bi-key text-primary" style="font-size: 2.5rem;"></i>
                            </div>
                        </div>
                        <h4 class="mb-3">Masukkan Kode Sesi</h4>
                        <p class="text-muted mb-4">Masukkan 6 karakter kode absensi yang diberikan oleh admin/pengajar</p>

                        <form id="attendanceForm">
                            <div class="mb-4">
                                <input type="text" class="form-control form-control-lg text-center font-monospace"
                                       name="sessionCode" id="sessionCode" maxlength="6"
                                       placeholder="XXXXXX" style="text-transform: uppercase; letter-spacing: 0.5em;"
                                       autocomplete="off" required>
                            </div>
                            <button type="submit" class="btn btn-primary btn-lg px-5" id="submitBtn">
                                <i class="bi bi-check-lg me-2"></i>Absen Sekarang
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Active Sessions -->
        <h4 class="mb-3"><i class="bi bi-calendar-check me-2"></i>Sesi Aktif</h4>

        <% if (activeSessions != null && !activeSessions.isEmpty()) { %>
        <div class="row g-4">
            <% for (AttendanceSession sess : activeSessions) { %>
            <div class="col-md-6 col-lg-4">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="card-title mb-0"><%= sess.getSessionName() %></h5>
                            <span class="badge bg-success">Aktif</span>
                        </div>
                        <p class="text-muted small mb-3">
                            <i class="bi bi-calendar me-1"></i>
                            <%= new java.text.SimpleDateFormat("dd MMM yyyy").format(sess.getSessionDate()) %>
                        </p>
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <span class="text-muted small">
                                <i class="bi bi-clock me-1"></i>
                                <%= new java.text.SimpleDateFormat("HH:mm").format(sess.getStartTime()) %> -
                                <%= new java.text.SimpleDateFormat("HH:mm").format(sess.getEndTime()) %>
                            </span>
                            <% if (sess.getTargetTag() != null && !sess.getTargetTag().isEmpty()) { %>
                            <span class="badge bg-info"><%= sess.getTargetTag() %></span>
                            <% } %>
                        </div>
                        <button type="button" class="btn btn-outline-primary w-100 use-code-btn"
                                data-code="<%= sess.getSessionCode() %>">
                            <i class="bi bi-check2-square me-1"></i>Gunakan Kode
                        </button>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="card">
            <div class="card-body text-center py-5">
                <i class="bi bi-calendar-x display-1 text-muted mb-3 d-block"></i>
                <h5 class="text-muted">Tidak ada sesi aktif</h5>
                <p class="text-muted">Sesi absensi akan muncul di sini setelah admin mengaktifkannya.</p>
            </div>
        </div>
        <% } %>
    </div>

    <!-- Footer -->
    <footer class="bg-light py-3 mt-auto">
        <div class="container text-center">
            <span class="text-muted">&copy; 2026 Examora. All rights reserved.</span>
        </div>
    </footer>

    <!-- Success Modal -->
    <div class="modal fade" id="successModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-success text-white border-0">
                    <h5 class="modal-title">
                        <i class="bi bi-check-circle me-2"></i>Absensi Berhasil!
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <div class="mb-4">
                        <div class="bg-success bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center"
                             style="width: 80px; height: 80px;">
                            <i class="bi bi-check-lg text-success" style="font-size: 2.5rem;"></i>
                        </div>
                    </div>
                    <h5 class="mb-3" id="successSessionName">Nama Sesi</h5>
                    <p class="text-muted mb-3">Waktu: <span id="successTime"></span></p>
                    <div class="d-flex justify-content-center">
                        <span class="badge fs-6" id="successStatus"></span>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-success px-4" data-bs-dismiss="modal">
                        <i class="bi bi-check-lg me-1"></i>Tutup
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto uppercase for session code input
        document.getElementById('sessionCode').addEventListener('input', function(e) {
            this.value = this.value.toUpperCase();
        });

        // Form submit
        document.getElementById('attendanceForm').addEventListener('submit', function(e) {
            e.preventDefault();

            const code = document.getElementById('sessionCode').value.trim();
            if (code.length !== 6) {
                alert('Kode harus 6 karakter');
                return;
            }

            const submitBtn = document.getElementById('submitBtn');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Memproses...';

            const params = new URLSearchParams();
            params.append('action', 'join');
            params.append('sessionCode', code);

            fetch('AttendanceServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
            .then(response => response.json())
            .then(data => {
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="bi bi-check-lg me-2"></i>Absen Sekarang';

                if (data.success) {
                    document.getElementById('successSessionName').textContent = data.sessionName;
                    document.getElementById('successTime').textContent = new Date().toLocaleTimeString('id-ID');
                    const statusBadge = document.getElementById('successStatus');
                    statusBadge.textContent = data.statusLabel;
                    statusBadge.className = 'badge fs-6 ' + (data.status === 'present' ? 'bg-success' : 'bg-warning text-dark');

                    const modal = new bootstrap.Modal(document.getElementById('successModal'));
                    modal.show();

                    document.getElementById('sessionCode').value = '';
                } else {
                    alert('Error: ' + data.message);
                }
            })
            .catch(error => {
                submitBtn.disabled = false;
                submitBtn.innerHTML = '<i class="bi bi-check-lg me-2"></i>Absen Sekarang';
                alert('Error: ' + error);
            });
        });

        // Use code buttons
        document.querySelectorAll('.use-code-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                document.getElementById('sessionCode').value = this.dataset.code;
                document.getElementById('sessionCode').focus();
            });
        });
    </script>
</body>
</html>
