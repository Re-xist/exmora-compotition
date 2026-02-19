<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="com.examora.model.AttendanceSession" %>
<%@ page import="com.examora.model.AttendanceRecord" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }

    AttendanceSession attSession = (AttendanceSession) request.getAttribute("session");
    List<AttendanceRecord> records = (List<AttendanceRecord>) request.getAttribute("records");
    Integer statsPresent = (Integer) request.getAttribute("statsPresent");
    Integer statsLate = (Integer) request.getAttribute("statsLate");
    Integer statsTotal = (Integer) request.getAttribute("statsTotal");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail Absensi - Examora</title>
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
                <a href="../SettingsServlet">
                    <i class="bi bi-gear"></i>Pengaturan
                </a>
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
                <a href="../AttendanceServlet?action=list" class="btn btn-outline-secondary btn-sm mb-2">
                    <i class="bi bi-arrow-left me-1"></i>Kembali
                </a>
                <h1 class="h3 mb-0"><%= attSession != null ? attSession.getSessionName() : "Detail Absensi" %></h1>
                <p class="text-muted mb-0">Rekap kehadiran peserta</p>
            </div>
            <div>
                <% if (attSession != null) { %>
                <a href="AttendanceServlet?action=export&sessionId=<%= attSession.getId() %>&format=csv"
                   class="btn btn-outline-success">
                    <i class="bi bi-file-earmark-excel me-2"></i>Export CSV
                </a>
                <a href="AttendanceServlet?action=export&sessionId=<%= attSession.getId() %>&format=pdf"
                   class="btn btn-outline-danger">
                    <i class="bi bi-file-earmark-pdf me-2"></i>Export PDF
                </a>
                <% } %>
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

        <% if (attSession != null) { %>
        <!-- Session Info Card -->
        <div class="card mb-4">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3">
                        <p class="text-muted mb-1">Kode Sesi</p>
                        <h4 class="font-monospace text-primary"><%= attSession.getSessionCode() %></h4>
                    </div>
                    <div class="col-md-3">
                        <p class="text-muted mb-1">Tanggal</p>
                        <h5><%= new java.text.SimpleDateFormat("dd MMMM yyyy").format(attSession.getSessionDate()) %></h5>
                    </div>
                    <div class="col-md-3">
                        <p class="text-muted mb-1">Waktu</p>
                        <h5>
                            <%= new java.text.SimpleDateFormat("HH:mm").format(attSession.getStartTime()) %> -
                            <%= new java.text.SimpleDateFormat("HH:mm").format(attSession.getEndTime()) %>
                        </h5>
                    </div>
                    <div class="col-md-3">
                        <p class="text-muted mb-1">Status</p>
                        <h5><span class="badge <%= attSession.getStatusBadgeClass() %>"><%= attSession.getStatusLabel() %></span></h5>
                    </div>
                </div>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="card bg-success text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Hadir</p>
                                <h2 class="mb-0"><%= statsPresent != null ? statsPresent : 0 %></h2>
                            </div>
                            <i class="bi bi-check-circle fs-1 opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-warning">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Terlambat</p>
                                <h2 class="mb-0"><%= statsLate != null ? statsLate : 0 %></h2>
                            </div>
                            <i class="bi bi-clock fs-1 opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-info text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Total Hadir</p>
                                <h2 class="mb-0"><%= statsTotal != null ? statsTotal : 0 %></h2>
                            </div>
                            <i class="bi bi-people fs-1 opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Records Table -->
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="bi bi-list-ul me-2"></i>Daftar Kehadiran</h5>
            </div>
            <div class="card-body">
                <% if (records != null && !records.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>No</th>
                                <th>Nama</th>
                                <th>Email</th>
                                <th>Tag</th>
                                <th>Waktu Absensi</th>
                                <th>Status</th>
                                <th>Catatan</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int no = 1;
                               for (AttendanceRecord record : records) { %>
                            <tr>
                                <td><%= no++ %></td>
                                <td><%= record.getUserName() != null ? record.getUserName() : "-" %></td>
                                <td><%= record.getUserEmail() != null ? record.getUserEmail() : "-" %></td>
                                <td>
                                    <% if (record.getUserTag() != null && !record.getUserTag().isEmpty()) { %>
                                    <span class="badge bg-info"><%= record.getUserTag() %></span>
                                    <% } else { %>
                                    <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                                <td><%= record.getFormattedAttendanceTime() %></td>
                                <td>
                                    <span class="badge <%= record.getStatusBadgeClass() %>"><%= record.getStatusLabel() %></span>
                                </td>
                                <td><%= record.getNotes() != null ? record.getNotes() : "-" %></td>
                                <td>
                                    <button class="btn btn-sm btn-outline-primary edit-record-btn"
                                            data-record-id="<%= record.getId() %>"
                                            data-status="<%= record.getStatus() %>"
                                            data-notes="<%= record.getNotes() != null ? record.getNotes() : "" %>">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-4 text-muted">
                    <i class="bi bi-people display-4 d-block mb-2"></i>
                    Belum ada peserta yang melakukan absensi.
                </div>
                <% } %>
            </div>
        </div>
        <% } else { %>
        <div class="alert alert-warning">
            <i class="bi bi-exclamation-triangle me-2"></i>Sesi tidak ditemukan.
        </div>
        <% } %>
    </div>

    <!-- Edit Record Modal -->
    <div class="modal fade" id="editRecordModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-pencil me-2"></i>Edit Status Kehadiran</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="editRecordForm">
                        <input type="hidden" name="recordId" id="editRecordId">
                        <div class="mb-3">
                            <label class="form-label">Status</label>
                            <select class="form-select" name="status" id="editStatus">
                                <option value="present">Hadir</option>
                                <option value="late">Terlambat</option>
                                <option value="absent">Tidak Hadir</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Catatan</label>
                            <textarea class="form-control" name="notes" id="editNotes" rows="3"
                                      placeholder="Catatan tambahan (opsional)"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                    <button type="button" class="btn btn-primary" id="saveRecordBtn">
                        <i class="bi bi-check-lg me-2"></i>Simpan
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Edit record button click
        document.querySelectorAll('.edit-record-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                document.getElementById('editRecordId').value = this.dataset.recordId;
                document.getElementById('editStatus').value = this.dataset.status;
                document.getElementById('editNotes').value = this.dataset.notes;

                const modal = new bootstrap.Modal(document.getElementById('editRecordModal'));
                modal.show();
            });
        });

        // Save record
        document.getElementById('saveRecordBtn').addEventListener('click', function() {
            const form = document.getElementById('editRecordForm');
            const params = new URLSearchParams();
            params.append('action', 'updateRecord');
            params.append('recordId', document.getElementById('editRecordId').value);
            params.append('status', document.getElementById('editStatus').value);
            params.append('notes', document.getElementById('editNotes').value);

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
            })
            .catch(error => {
                alert('Error: ' + error);
            });
        });
    </script>
</body>
</html>
