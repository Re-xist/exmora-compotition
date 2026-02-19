<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.AttendanceSession" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    List<AttendanceSession> sessions = (List<AttendanceSession>) request.getAttribute("sessions");
    List<String> tags = (List<String>) request.getAttribute("tags");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Absensi - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
</head>
<body>
    <!-- Sidebar -->
    <nav class="sidebar">
        <a href="../AdminServlet?action=dashboard" class="sidebar-brand">
            <i class="bi bi-journal-check me-2"></i>Examora
        </a>
        <hr class="sidebar-divider bg-white opacity-25">
        <ul class="sidebar-menu">
            <li>
                <a href="../AdminServlet?action=dashboard">
                    <i class="bi bi-speedometer2"></i>Dashboard
                </a>
            </li>
            <li>
                <a href="../QuizServlet?action=list">
                    <i class="bi bi-journal-text"></i>Kelola Quiz
                </a>
            </li>
            <li>
                <a href="../ArenaServlet?action=list">
                    <i class="bi bi-trophy"></i>Kelola Arena
                </a>
            </li>
            <li>
                <a href="../AdminServlet?action=users">
                    <i class="bi bi-people"></i>Kelola User
                </a>
            </li>
            <li>
                <a href="../AttendanceServlet?action=list" class="active">
                    <i class="bi bi-check2-square"></i>Absensi
                </a>
            </li>
            <li>
                <a href="../AdminServlet?action=statistics">
                    <i class="bi bi-graph-up"></i>Statistik
                </a>
            </li>
            <li>
            </li>
            <li class="mt-5">
                <a href="../LogoutServlet">
                    <i class="bi bi-box-arrow-left"></i>Logout
                </a>
            </li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="h3 mb-0">Kelola Absensi</h1>
                <p class="text-muted mb-0">Buat dan kelola sesi absensi</p>
            </div>
            <div>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createSessionModal">
                    <i class="bi bi-plus-lg me-2"></i>Buat Sesi Absensi
                </button>
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

        <!-- Sessions Table -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-list-ul me-2"></i>Daftar Sesi Absensi</h5>
            </div>
            <div class="card-body">
                <% if (sessions != null && !sessions.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Nama Sesi</th>
                                <th>Kode</th>
                                <th>Tanggal</th>
                                <th>Waktu</th>
                                <th>Target Tag</th>
                                <th>Status</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (AttendanceSession attSession : sessions) { %>
                            <tr>
                                <td><%= attSession.getSessionName() %></td>
                                <td>
                                    <span class="badge bg-dark font-monospace"><%= attSession.getSessionCode() %></span>
                                </td>
                                <td><%= new java.text.SimpleDateFormat("dd MMM yyyy").format(attSession.getSessionDate()) %></td>
                                <td>
                                    <%= new java.text.SimpleDateFormat("HH:mm").format(attSession.getStartTime()) %> -
                                    <%= new java.text.SimpleDateFormat("HH:mm").format(attSession.getEndTime()) %>
                                </td>
                                <td>
                                    <% if (attSession.getTargetTag() != null && !attSession.getTargetTag().isEmpty()) { %>
                                    <span class="badge bg-info"><%= attSession.getTargetTag() %></span>
                                    <% } else { %>
                                    <span class="text-muted">Semua</span>
                                    <% } %>
                                </td>
                                <td>
                                    <span class="badge <%= attSession.getStatusBadgeClass() %>"><%= attSession.getStatusLabel() %></span>
                                </td>
                                <td>
                                    <% if ("scheduled".equals(attSession.getStatus())) { %>
                                    <button class="btn btn-sm btn-success activate-btn"
                                            data-session-id="<%= attSession.getId() %>" title="Aktifkan">
                                        <i class="bi bi-play-fill"></i>
                                    </button>
                                    <% } %>
                                    <% if ("active".equals(attSession.getStatus())) { %>
                                    <button class="btn btn-sm btn-warning close-btn"
                                            data-session-id="<%= attSession.getId() %>" title="Tutup">
                                        <i class="bi bi-stop-fill"></i>
                                    </button>
                                    <% } %>
                                    <a href="AttendanceServlet?action=view&sessionId=<%= attSession.getId() %>"
                                       class="btn btn-sm btn-info" title="Lihat Records">
                                        <i class="bi bi-people"></i>
                                    </a>
                                    <button class="btn btn-sm btn-outline-danger delete-btn"
                                            data-session-id="<%= attSession.getId() %>" title="Hapus">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-4 text-muted">
                    <i class="bi bi-calendar-x display-4 d-block mb-2"></i>
                    Belum ada sesi absensi. Klik tombol "Buat Sesi Absensi" untuk membuat sesi baru.
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Create Session Modal -->
    <div class="modal fade" id="createSessionModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-plus-circle me-2"></i>Buat Sesi Absensi Baru</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="createSessionForm">
                        <div class="mb-3">
                            <label class="form-label">Nama Sesi <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="sessionName" required
                                   placeholder="Contoh: Absensi Kuliah Pertemuan 1">
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tanggal <span class="text-danger">*</span></label>
                            <input type="date" class="form-control" name="sessionDate" required>
                        </div>
                        <div class="row mb-3">
                            <div class="col">
                                <label class="form-label">Waktu Mulai <span class="text-danger">*</span></label>
                                <input type="time" class="form-control" name="startTime" required>
                            </div>
                            <div class="col">
                                <label class="form-label">Waktu Selesai <span class="text-danger">*</span></label>
                                <input type="time" class="form-control" name="endTime" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Target Tag (Opsional)</label>
                            <select class="form-select" name="targetTag">
                                <option value="">-- Semua Peserta --</option>
                                <% if (tags != null) { %>
                                    <% for (String tag : tags) { %>
                                        <% if (tag != null && !tag.isEmpty()) { %>
                                        <option value="<%= tag %>"><%= tag %></option>
                                        <% } %>
                                    <% } %>
                                <% } %>
                            </select>
                            <div class="form-text">Hanya peserta dengan tag ini yang bisa absen</div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Batas Terlambat (menit)</label>
                            <input type="number" class="form-control" name="lateThreshold" value="15" min="0">
                            <div class="form-text">Setelah waktu ini, status absensi akan "Terlambat"</div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                    <button type="button" class="btn btn-primary" id="createSessionBtn">
                        <i class="bi bi-check-lg me-2"></i>Buat Sesi
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Success Modal -->
    <div class="modal fade" id="successModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title"><i class="bi bi-check-circle me-2"></i>Sesi Berhasil Dibuat!</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center">
                    <p class="mb-2">Kode Sesi:</p>
                    <h2 class="text-primary font-monospace mb-3" id="generatedCode"></h2>
                    <p class="text-muted">Share kode ini ke peserta untuk melakukan absensi</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Tutup</button>
                    <button type="button" class="btn btn-primary" id="copyCodeBtn">
                        <i class="bi bi-clipboard me-2"></i>Salin Kode
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Set default date to today
        document.querySelector('input[name="sessionDate"]').valueAsDate = new Date();

        // Create session
        document.getElementById('createSessionBtn').addEventListener('click', function() {
            const form = document.getElementById('createSessionForm');
            const formData = new FormData(form);
            const params = new URLSearchParams();
            params.append('action', 'create');
            for (let [key, value] of formData.entries()) {
                params.append(key, value);
            }

            fetch('AttendanceServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('HTTP error ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    const createModal = bootstrap.Modal.getInstance(document.getElementById('createSessionModal'));
                    createModal.hide();
                    form.reset();
                    document.querySelector('input[name="sessionDate"]').valueAsDate = new Date();

                    document.getElementById('generatedCode').textContent = data.sessionCode;
                    const successModal = new bootstrap.Modal(document.getElementById('successModal'));
                    successModal.show();

                    setTimeout(() => location.reload(), 2000);
                } else {
                    alert('Error: ' + (data.message || 'Terjadi kesalahan'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Error: ' + error.message);
            });
        });

        // Copy code
        document.getElementById('copyCodeBtn').addEventListener('click', function() {
            const code = document.getElementById('generatedCode').textContent;
            navigator.clipboard.writeText(code).then(() => {
                this.innerHTML = '<i class="bi bi-check me-2"></i>Tersalin!';
                setTimeout(() => {
                    this.innerHTML = '<i class="bi bi-clipboard me-2"></i>Salin Kode';
                }, 2000);
            });
        });

        // Activate session
        document.querySelectorAll('.activate-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                if (confirm('Aktifkan sesi ini?')) {
                    const sessionId = this.dataset.sessionId;
                    const params = new URLSearchParams();
                    params.append('action', 'activate');
                    params.append('sessionId', sessionId);

                    fetch('AttendanceServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: params
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            location.reload();
                        } else {
                            alert('Error: ' + (data.message || 'Terjadi kesalahan'));
                        }
                    });
                }
            });
        });

        // Close session
        document.querySelectorAll('.close-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                if (confirm('Tutup sesi ini?')) {
                    const sessionId = this.dataset.sessionId;
                    const params = new URLSearchParams();
                    params.append('action', 'close');
                    params.append('sessionId', sessionId);

                    fetch('AttendanceServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: params
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            location.reload();
                        } else {
                            alert('Error: ' + (data.message || 'Terjadi kesalahan'));
                        }
                    });
                }
            });
        });

        // Delete session
        document.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                if (confirm('Hapus sesi ini? Semua data absensi akan ikut terhapus.')) {
                    const sessionId = this.dataset.sessionId;
                    const params = new URLSearchParams();
                    params.append('action', 'delete');
                    params.append('sessionId', sessionId);

                    fetch('AttendanceServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: params
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            location.reload();
                        } else {
                            alert('Error: ' + (data.message || 'Terjadi kesalahan'));
                        }
                    });
                }
            });
        });
    </script>
</body>
</html>
