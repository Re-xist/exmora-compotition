<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.examora.model.User" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !currentUser.isAdmin()) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
    List<String> tags = (List<String>) request.getAttribute("tags");
    String roleFilter = (String) request.getAttribute("roleFilter");
    String tagFilter = (String) request.getAttribute("tagFilter");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola User - Examora</title>
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
                <h1 class="h3 mb-0">Kelola User</h1>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0">
                        <li class="breadcrumb-item"><a href="../AdminServlet?action=dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item active">User</li>
                    </ol>
                </nav>
            </div>
            <div class="d-flex gap-2 flex-wrap">
                <button type="button" class="btn btn-outline-danger" data-bs-toggle="modal" data-bs-target="#gdriveLinksModal">
                    <i class="bi bi-google me-2"></i>Link Google Drive
                </button>
                <a href="../AdminServlet?action=downloadTemplate" class="btn btn-outline-success">
                    <i class="bi bi-file-earmark-spreadsheet me-2"></i>Template CSV
                </a>
                <button type="button" class="btn btn-outline-info" data-bs-toggle="modal" data-bs-target="#createTagModal">
                    <i class="bi bi-tag me-2"></i>Kelola Tag
                </button>
                <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#importCsvModal">
                    <i class="bi bi-upload me-2"></i>Import CSV
                </button>
                <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createUserModal">
                    <i class="bi bi-person-plus me-2"></i>Tambah User
                </button>
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

        <!-- Filter -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="../AdminServlet" class="row g-3 align-items-center">
                    <input type="hidden" name="action" value="users">
                    <div class="col-auto">
                        <label class="form-label mb-0"><i class="bi bi-funnel me-2"></i>Filter:</label>
                    </div>
                    <div class="col-auto">
                        <select name="role" class="form-select" onchange="this.form.submit()">
                            <option value="">Semua Role</option>
                            <option value="admin" <%= "admin".equals(roleFilter) ? "selected" : "" %>>Admin</option>
                            <option value="peserta" <%= "peserta".equals(roleFilter) ? "selected" : "" %>>Peserta</option>
                        </select>
                    </div>
                    <div class="col-auto">
                        <select name="tag" class="form-select" onchange="this.form.submit()">
                            <option value="">Semua Tag</option>
                            <% if (tags != null) {
                                for (String tag : tags) { %>
                            <option value="<%= tag %>" <%= tag.equals(tagFilter) ? "selected" : "" %>><%= tag %></option>
                            <% }
                            } %>
                        </select>
                    </div>
                    <div class="col-auto">
                        <a href="../AdminServlet?action=users" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-counterclockwise me-1"></i>Reset
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- User Stats -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card stat-card bg-primary text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Total User</p>
                                <h2 class="stat-value mb-0"><%= users != null ? users.size() : 0 %></h2>
                            </div>
                            <i class="bi bi-people stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stat-card bg-success text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Admin</p>
                                <h2 class="stat-value mb-0">
                                    <%= users != null ? users.stream().filter(u -> u.isAdmin()).count() : 0 %>
                                </h2>
                            </div>
                            <i class="bi bi-person-badge stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stat-card bg-info text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <p class="mb-1 opacity-75">Peserta</p>
                                <h2 class="stat-value mb-0">
                                    <%= users != null ? users.stream().filter(u -> u.isPeserta()).count() : 0 %>
                                </h2>
                            </div>
                            <i class="bi bi-mortarboard stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- User List -->
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h6 class="mb-0"><i class="bi bi-people me-2"></i>Daftar User</h6>
            </div>
            <div class="card-body">
                <% if (users != null && !users.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Nama</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Tag</th>
                                <th>Terdaftar</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% int no = 1; for (User user : users) { %>
                            <tr>
                                <td><%= no++ %></td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="avatar-circle bg-<%= user.isAdmin() ? "primary" : "success" %> text-white me-2">
                                            <%= user.getName() != null && user.getName().length() > 0 ?
                                                user.getName().substring(0, 1).toUpperCase() : "U" %>
                                        </div>
                                        <strong><%= user.getName() %></strong>
                                    </div>
                                </td>
                                <td><%= user.getEmail() %></td>
                                <td>
                                    <% if (user.isAdmin()) { %>
                                    <span class="badge bg-primary"><i class="bi bi-shield-check me-1"></i>Admin</span>
                                    <% } else { %>
                                    <span class="badge bg-success"><i class="bi bi-person me-1"></i>Peserta</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (user.getTag() != null && !user.getTag().isEmpty()) { %>
                                    <span class="badge bg-info"><i class="bi bi-tag me-1"></i><%= user.getTag() %></span>
                                    <% } else { %>
                                    <span class="text-muted">-</span>
                                    <% } %>
                                </td>
                                <td><%= user.getCreatedAt() != null ? user.getCreatedAt().toLocalDate() : "-" %></td>
                                <td>
                                    <div class="btn-group btn-group-sm">
                                        <button type="button" class="btn btn-outline-info" title="Detail"
                                                onclick="showUserDetail(<%= user.getId() %>, '<%= user.getName() %>',
                                                '<%= user.getEmail() %>', '<%= user.getRole() %>',
                                                '<%= user.getTag() != null ? user.getTag().replace("'", "\\'") : "" %>',
                                                '<%= user.getCreatedAt() != null ? user.getCreatedAt().toLocalDate() : "-" %>',
                                                '<%= user.getGdriveLink() != null ? user.getGdriveLink().replace("'", "\\'") : "" %>')">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                        <button type="button" class="btn btn-outline-warning" title="Edit"
                                                onclick="showEditModal(<%= user.getId() %>, '<%= user.getName() %>',
                                                '<%= user.getEmail() %>', '<%= user.getRole() %>',
                                                '<%= user.getTag() != null ? user.getTag().replace("'", "\\'") : "" %>',
                                                '<%= user.getGdriveLink() != null ? user.getGdriveLink().replace("'", "\\'") : "" %>')">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <button type="button" class="btn btn-outline-secondary" title="Reset Password"
                                                onclick="showResetPasswordModal(<%= user.getId() %>, '<%= user.getName() %>')">
                                            <i class="bi bi-key"></i>
                                        </button>
                                        <% if (!user.isAdmin() || !user.getEmail().equals("admin@examora.com")) { %>
                                        <button type="button" class="btn btn-outline-danger" title="Hapus"
                                                onclick="confirmDelete(<%= user.getId() %>, '<%= user.getName() %>')">
                                            <i class="bi bi-trash"></i>
                                        </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="text-center py-5">
                    <i class="bi bi-people display-1 text-muted mb-3 d-block"></i>
                    <h4 class="text-muted">Tidak ada user</h4>
                    <p class="text-muted">Belum ada user terdaftar dalam sistem.</p>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- User Detail Modal -->
    <div class="modal fade" id="userDetailModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-person-circle me-2"></i>Detail User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="text-center mb-3">
                        <div class="avatar-circle-lg bg-primary text-white mx-auto">
                            <span id="modalAvatar">U</span>
                        </div>
                        <h5 class="mt-2" id="modalName">User Name</h5>
                    </div>
                    <table class="table table-borderless">
                        <tr>
                            <td class="text-muted">Email:</td>
                            <td id="modalEmail">email@example.com</td>
                        </tr>
                        <tr>
                            <td class="text-muted">Role:</td>
                            <td id="modalRole">Peserta</td>
                        </tr>
                        <tr>
                            <td class="text-muted">Tag:</td>
                            <td id="modalTag">-</td>
                        </tr>
                        <tr>
                            <td class="text-muted">Google Drive:</td>
                            <td id="modalGdrive">-</td>
                        </tr>
                        <tr>
                            <td class="text-muted">Terdaftar:</td>
                            <td id="modalDate">2024-01-01</td>
                        </tr>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Tutup</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title"><i class="bi bi-exclamation-triangle me-2"></i>Konfirmasi Hapus</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Apakah Anda yakin ingin menghapus user <strong id="deleteUserName"></strong>?</p>
                    <p class="text-muted small mb-0">
                        <i class="bi bi-info-circle me-1"></i>
                        Semua riwayat ujian user ini juga akan dihapus.
                    </p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                    <form action="../AdminServlet" method="post" style="display: inline;">
                        <input type="hidden" name="action" value="deleteUser">
                        <input type="hidden" name="userId" id="deleteUserId">
                        <button type="submit" class="btn btn-danger">
                            <i class="bi bi-trash me-1"></i>Ya, Hapus
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Create User Modal -->
    <div class="modal fade" id="createUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="bi bi-person-plus me-2"></i>Tambah User Baru</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form action="../AdminServlet" method="post">
                        <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
                    <input type="hidden" name="action" value="createUser">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Nama Lengkap</label>
                            <input type="text" class="form-control" name="name" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" name="email" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Password</label>
                            <input type="password" class="form-control" name="password" required minlength="6">
                            <small class="text-muted">Minimal 6 karakter</small>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Role</label>
                            <select class="form-select" name="role" required>
                                <option value="peserta">Peserta</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tag</label>
                            <div class="input-group">
                                <select class="form-select" name="tag" id="createTagSelect">
                                    <option value="">-- Tanpa Tag --</option>
                                    <% if (tags != null) {
                                        for (String tag : tags) { %>
                                    <option value="<%= tag %>"><%= tag %></option>
                                    <% }
                                    } %>
                                </select>
                                <button type="button" class="btn btn-outline-secondary" onclick="showNewTagInput()">
                                    <i class="bi bi-plus"></i> Tag Baru
                                </button>
                            </div>
                            <div id="newTagInputWrapper" class="mt-2" style="display: none;">
                                <input type="text" class="form-control" name="newTag" id="newTagInput"
                                       placeholder="Masukkan nama tag baru">
                                <small class="text-muted">Tag baru akan digunakan untuk user ini</small>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Link Google Drive</label>
                            <input type="url" class="form-control" name="gdriveLink" placeholder="https://drive.google.com/...">
                            <small class="text-muted">Opsional: Link ke folder/file Google Drive user</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i>Simpan
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit User Modal -->
    <div class="modal fade" id="editUserModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-warning">
                    <h5 class="modal-title"><i class="bi bi-pencil me-2"></i>Edit User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form action="../AdminServlet" method="post">
                        <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
                    <input type="hidden" name="action" value="editUser">
                    <input type="hidden" name="userId" id="editUserId">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label">Nama Lengkap</label>
                            <input type="text" class="form-control" name="name" id="editName" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" name="email" id="editEmail" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Role</label>
                            <select class="form-select" name="role" id="editRole" required>
                                <option value="peserta">Peserta</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tag</label>
                            <div class="input-group">
                                <select class="form-select" name="tag" id="editTagSelect">
                                    <option value="">-- Tanpa Tag --</option>
                                    <% if (tags != null) {
                                        for (String tag : tags) { %>
                                    <option value="<%= tag %>"><%= tag %></option>
                                    <% }
                                    } %>
                                </select>
                                <button type="button" class="btn btn-outline-secondary" onclick="showEditNewTagInput()">
                                    <i class="bi bi-plus"></i> Tag Baru
                                </button>
                            </div>
                            <div id="editNewTagInputWrapper" class="mt-2" style="display: none;">
                                <input type="text" class="form-control" name="newTag" id="editNewTagInput"
                                       placeholder="Masukkan nama tag baru">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Link Google Drive</label>
                            <input type="url" class="form-control" name="gdriveLink" id="editGdriveLink" placeholder="https://drive.google.com/...">
                            <small class="text-muted">Opsional: Link ke folder/file Google Drive user</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-warning">
                            <i class="bi bi-check-lg me-1"></i>Update
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Reset Password Modal -->
    <div class="modal fade" id="resetPasswordModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-secondary text-white">
                    <h5 class="modal-title"><i class="bi bi-key me-2"></i>Reset Password</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form action="../AdminServlet" method="post">
                        <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
                    <input type="hidden" name="action" value="resetPassword">
                    <input type="hidden" name="userId" id="resetPasswordUserId">
                    <div class="modal-body">
                        <p>Reset password untuk: <strong id="resetPasswordUserName"></strong></p>
                        <div class="mb-3">
                            <label class="form-label">Password Baru</label>
                            <input type="password" class="form-control" name="newPassword" required minlength="6">
                            <small class="text-muted">Minimal 6 karakter</small>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i>Reset Password
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Create Tag Modal -->
    <div class="modal fade" id="createTagModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title"><i class="bi bi-tag me-2"></i>Kelola Tag</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <!-- Existing Tags -->
                    <div class="mb-4">
                        <h6 class="text-muted mb-3">Tag yang Tersedia</h6>
                        <div id="existingTagsList" class="d-flex flex-wrap gap-2">
                            <% if (tags != null && !tags.isEmpty()) {
                                for (String tag : tags) { %>
                            <span class="badge bg-info fs-6 p-2">
                                <i class="bi bi-tag me-1"></i><%= tag %>
                            </span>
                            <% }
                            } else { %>
                            <span class="text-muted">Belum ada tag</span>
                            <% } %>
                        </div>
                    </div>

                    <!-- Add New Tag Form -->
                    <div class="border-top pt-3">
                        <h6 class="text-muted mb-3">Tambah Tag Baru</h6>
                        <form id="createTagForm" onsubmit="return createTag(event)">
                            <div class="input-group">
                                <input type="text" class="form-control" id="newTagName"
                                       placeholder="Nama tag baru (contoh: Kelas A, Divisi IT)" required>
                                <button type="submit" class="btn btn-info text-white">
                                    <i class="bi bi-plus-lg me-1"></i>Tambah
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Tutup</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Import CSV Modal -->
    <div class="modal fade" id="importCsvModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title"><i class="bi bi-upload me-2"></i>Import User dari CSV</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form action="../AdminServlet" method="post" enctype="multipart/form-data" id="importCsvForm">
                    <input type="hidden" name="action" value="importUsers">
                    <div class="modal-body">
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle me-2"></i>
                            <strong>Format CSV:</strong>
                            <ul class="mb-0 mt-2 small">
                                <li><strong>nama</strong> - Nama lengkap user</li>
                                <li><strong>email</strong> - Email user (harus unik)</li>
                                <li><strong>password</strong> - Password (minimal 6 karakter)</li>
                                <li><strong>role</strong> - Role: "peserta" atau "admin" (default: peserta)</li>
                                <li><strong>tag</strong> - Tag user (opsional)</li>
                            </ul>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Pilih File CSV</label>
                            <input type="file" class="form-control" name="csvFile" accept=".csv" required>
                            <small class="text-muted">Format file: .csv (Max 5MB)</small>
                        </div>

                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" name="skipHeader" id="skipHeader" checked>
                            <label class="form-check-label" for="skipHeader">
                                Lewati baris pertama (header)
                            </label>
                        </div>

                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="updateExisting" id="updateExisting">
                            <label class="form-check-label" for="updateExisting">
                                Update user jika email sudah ada
                            </label>
                        </div>

                        <div id="importPreview" class="mt-3" style="display: none;">
                            <h6>Preview Data:</h6>
                            <div class="table-responsive" style="max-height: 200px;">
                                <table class="table table-sm table-bordered" id="previewTable">
                                    <thead class="table-light">
                                        <tr><th>Nama</th><th>Email</th><th>Role</th><th>Tag</th></tr>
                                    </thead>
                                    <tbody></tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Batal</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-upload me-1"></i>Import
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Import Result Modal -->
    <div class="modal fade" id="importResultModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-check-circle me-2"></i>Hasil Import</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="importResultBody">
                    <!-- Will be filled dynamically -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">Tutup</button>
                </div>
            </div>
        </div>
    </div>

    <style>
        .avatar-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1rem;
        }
        .avatar-circle-lg {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 2rem;
        }
    </style>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function showUserDetail(id, name, email, role, tag, date, gdriveLink) {
            document.getElementById('modalAvatar').textContent = name.charAt(0).toUpperCase();
            document.getElementById('modalName').textContent = name;
            document.getElementById('modalEmail').textContent = email;
            document.getElementById('modalRole').innerHTML = role === 'admin'
                ? '<span class="badge bg-primary"><i class="bi bi-shield-check me-1"></i>Admin</span>'
                : '<span class="badge bg-success"><i class="bi bi-person me-1"></i>Peserta</span>';
            document.getElementById('modalTag').innerHTML = tag && tag.trim() !== ''
                ? '<span class="badge bg-info"><i class="bi bi-tag me-1"></i>' + tag + '</span>'
                : '<span class="text-muted">-</span>';
            document.getElementById('modalGdrive').innerHTML = gdriveLink && gdriveLink.trim() !== ''
                ? '<a href="' + gdriveLink + '" target="_blank" class="btn btn-sm btn-outline-danger"><i class="bi bi-google me-1"></i>Buka Link</a>'
                : '<span class="text-muted">-</span>';
            document.getElementById('modalDate').textContent = date;

            new bootstrap.Modal(document.getElementById('userDetailModal')).show();
        }

        function confirmDelete(userId, userName) {
            document.getElementById('deleteUserId').value = userId;
            document.getElementById('deleteUserName').textContent = userName;
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }

        function showEditModal(userId, name, email, role, tag, gdriveLink) {
            document.getElementById('editUserId').value = userId;
            document.getElementById('editName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editRole').value = role;
            document.getElementById('editGdriveLink').value = gdriveLink || '';

            // Set tag select value
            var tagSelect = document.getElementById('editTagSelect');
            var tagFound = false;
            for (var i = 0; i < tagSelect.options.length; i++) {
                if (tagSelect.options[i].value === tag) {
                    tagSelect.selectedIndex = i;
                    tagFound = true;
                    break;
                }
            }
            if (!tagFound) {
                tagSelect.selectedIndex = 0; // Select "-- Tanpa Tag --"
            }

            // Hide new tag input wrapper
            document.getElementById('editNewTagInputWrapper').style.display = 'none';
            document.getElementById('editNewTagInput').value = '';

            new bootstrap.Modal(document.getElementById('editUserModal')).show();
        }

        function showResetPasswordModal(userId, userName) {
            document.getElementById('resetPasswordUserId').value = userId;
            document.getElementById('resetPasswordUserName').textContent = userName;
            new bootstrap.Modal(document.getElementById('resetPasswordModal')).show();
        }

        function showNewTagInput() {
            var wrapper = document.getElementById('newTagInputWrapper');
            var input = document.getElementById('newTagInput');
            wrapper.style.display = 'block';
            input.focus();
            // Deselect the dropdown
            document.getElementById('createTagSelect').selectedIndex = 0;
        }

        function showEditNewTagInput() {
            var wrapper = document.getElementById('editNewTagInputWrapper');
            var input = document.getElementById('editNewTagInput');
            wrapper.style.display = 'block';
            input.focus();
            // Deselect the dropdown
            document.getElementById('editTagSelect').selectedIndex = 0;
        }

        function createTag(event) {
            event.preventDefault();
            var tagName = document.getElementById('newTagName').value.trim();

            if (!tagName) {
                alert('Nama tag tidak boleh kosong');
                return false;
            }

            fetch('../AdminServlet?action=createTag&tagName=' + encodeURIComponent(tagName), {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Add new tag to the list
                    var tagsList = document.getElementById('existingTagsList');
                    var newBadge = document.createElement('span');
                    newBadge.className = 'badge bg-info fs-6 p-2';
                    newBadge.innerHTML = '<i class="bi bi-tag me-1"></i>' + tagName;
                    tagsList.appendChild(newBadge);

                    // Add to both select dropdowns
                    addTagToSelect('createTagSelect', tagName);
                    addTagToSelect('editTagSelect', tagName);

                    // Clear input
                    document.getElementById('newTagName').value = '';

                    alert('Tag "' + tagName + '" berhasil dibuat!');
                } else {
                    alert('Gagal membuat tag: ' + (data.error || 'Unknown error'));
                }
            })
            .catch(error => {
                alert('Error: ' + error.message);
            });

            return false;
        }

        function addTagToSelect(selectId, tagName) {
            var select = document.getElementById(selectId);
            var option = document.createElement('option');
            option.value = tagName;
            option.textContent = tagName;
            select.appendChild(option);
        }

        // Handle form submission to use new tag if provided
        document.addEventListener('DOMContentLoaded', function() {
            var createUserForm = document.querySelector('#createUserModal form');
            if (createUserForm) {
                createUserForm.addEventListener('submit', function(e) {
                    var newTagInput = document.getElementById('newTagInput');
                    var tagSelect = document.getElementById('createTagSelect');

                    if (newTagInput && newTagInput.value.trim()) {
                        // Use new tag value instead of select
                        var hiddenInput = document.createElement('input');
                        hiddenInput.type = 'hidden';
                        hiddenInput.name = 'tag';
                        hiddenInput.value = newTagInput.value.trim();
                        this.appendChild(hiddenInput);

                        // Remove select name to avoid conflict
                        tagSelect.removeAttribute('name');
                    }
                });
            }

            var editUserForm = document.querySelector('#editUserModal form');
            if (editUserForm) {
                editUserForm.addEventListener('submit', function(e) {
                    var newTagInput = document.getElementById('editNewTagInput');
                    var tagSelect = document.getElementById('editTagSelect');

                    if (newTagInput && newTagInput.value.trim()) {
                        // Use new tag value instead of select
                        var hiddenInput = document.createElement('input');
                        hiddenInput.type = 'hidden';
                        hiddenInput.name = 'tag';
                        hiddenInput.value = newTagInput.value.trim();
                        this.appendChild(hiddenInput);

                        // Remove select name to avoid conflict
                        tagSelect.removeAttribute('name');
                    }
                });
            }
        });
    </script>

    <!-- Google Drive Links Modal -->
    <div class="modal fade" id="gdriveLinksModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title"><i class="bi bi-google me-2"></i>Link Google Drive Peserta</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>Nama</th>
                                    <th>Tag</th>
                                    <th>Link Google Drive</th>
                                    <th>Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (users != null) {
                                    boolean hasGdriveLinks = false;
                                    for (User user : users) {
                                        if (user.getGdriveLink() != null && !user.getGdriveLink().isEmpty()) {
                                            hasGdriveLinks = true;
                                %>
                                <tr>
                                    <td><%= user.getName() %></td>
                                    <td>
                                        <% if (user.getTag() != null && !user.getTag().isEmpty()) { %>
                                        <span class="badge bg-info"><%= user.getTag() %></span>
                                        <% } else { %>
                                        <span class="text-muted">-</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <a href="<%= user.getGdriveLink() %>" target="_blank" class="text-truncate d-inline-block" style="max-width: 250px;">
                                            <%= user.getGdriveLink().length() > 40 ? user.getGdriveLink().substring(0, 40) + "..." : user.getGdriveLink() %>
                                        </a>
                                    </td>
                                    <td>
                                        <a href="<%= user.getGdriveLink() %>" target="_blank" class="btn btn-sm btn-outline-danger">
                                            <i class="bi bi-box-arrow-up-right"></i> Buka
                                        </a>
                                    </td>
                                </tr>
                                <%      }
                                    }
                                    if (!hasGdriveLinks) { %>
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-4">
                                        <i class="bi bi-google display-4 d-block mb-2"></i>
                                        Belum ada user yang memiliki link Google Drive
                                    </td>
                                </tr>
                                <%    }
                                } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Tutup</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
