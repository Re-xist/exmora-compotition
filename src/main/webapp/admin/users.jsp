<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <nav class="sidebar">
        <a href="../index.jsp" class="sidebar-brand">
            <i class="bi bi-journal-check me-2"></i>Examora
        </a>
        <hr class="sidebar-divider bg-white opacity-25">
        <ul class="sidebar-menu">
            <li><a href="../AdminServlet?action=dashboard"><i class="bi bi-speedometer2"></i>Dashboard</a></li>
            <li><a href="../QuizServlet?action=list"><i class="bi bi-journal-text"></i>Kelola Quiz</a></li>
            <li><a href="../AdminServlet?action=users" class="active"><i class="bi bi-people"></i>Kelola User</a></li>
            <li><a href="../AdminServlet?action=statistics"><i class="bi bi-graph-up"></i>Statistik</a></li>
            <li><a href="../SettingsServlet"><i class="bi bi-gear"></i>Pengaturan</a></li>
            <li class="mt-5"><a href="../LogoutServlet"><i class="bi bi-box-arrow-left"></i>Logout</a></li>
        </ul>
    </nav>

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
            <div>
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
                                                '<%= user.getCreatedAt() != null ? user.getCreatedAt().toLocalDate() : "-" %>')">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                        <button type="button" class="btn btn-outline-warning" title="Edit"
                                                onclick="showEditModal(<%= user.getId() %>, '<%= user.getName() %>',
                                                '<%= user.getEmail() %>', '<%= user.getRole() %>',
                                                '<%= user.getTag() != null ? user.getTag().replace("'", "\\'") : "" %>')">
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
                            <input type="text" class="form-control" name="tag" id="createTag"
                                   list="tagList" placeholder="Contoh: Kelas A, Divisi IT, dll">
                            <datalist id="tagList">
                                <% if (tags != null) {
                                    for (String tag : tags) { %>
                                <option value="<%= tag %>">
                                <% }
                                } %>
                            </datalist>
                            <small class="text-muted">Tag untuk mengelompokkan user (opsional)</small>
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
                            <input type="text" class="form-control" name="tag" id="editTag"
                                   list="tagListEdit" placeholder="Contoh: Kelas A, Divisi IT, dll">
                            <datalist id="tagListEdit">
                                <% if (tags != null) {
                                    for (String tag : tags) { %>
                                <option value="<%= tag %>">
                                <% }
                                } %>
                            </datalist>
                            <small class="text-muted">Tag untuk mengelompokkan user (opsional)</small>
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
        function showUserDetail(id, name, email, role, tag, date) {
            document.getElementById('modalAvatar').textContent = name.charAt(0).toUpperCase();
            document.getElementById('modalName').textContent = name;
            document.getElementById('modalEmail').textContent = email;
            document.getElementById('modalRole').innerHTML = role === 'admin'
                ? '<span class="badge bg-primary"><i class="bi bi-shield-check me-1"></i>Admin</span>'
                : '<span class="badge bg-success"><i class="bi bi-person me-1"></i>Peserta</span>';
            document.getElementById('modalTag').innerHTML = tag && tag.trim() !== ''
                ? '<span class="badge bg-info"><i class="bi bi-tag me-1"></i>' + tag + '</span>'
                : '<span class="text-muted">-</span>';
            document.getElementById('modalDate').textContent = date;

            new bootstrap.Modal(document.getElementById('userDetailModal')).show();
        }

        function confirmDelete(userId, userName) {
            document.getElementById('deleteUserId').value = userId;
            document.getElementById('deleteUserName').textContent = userName;
            new bootstrap.Modal(document.getElementById('deleteModal')).show();
        }

        function showEditModal(userId, name, email, role, tag) {
            document.getElementById('editUserId').value = userId;
            document.getElementById('editName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editRole').value = role;
            document.getElementById('editTag').value = tag || '';
            new bootstrap.Modal(document.getElementById('editUserModal')).show();
        }

        function showResetPasswordModal(userId, userName) {
            document.getElementById('resetPasswordUserId').value = userId;
            document.getElementById('resetPasswordUserName').textContent = userName;
            new bootstrap.Modal(document.getElementById('resetPasswordModal')).show();
        }
    </script>
</body>
</html>
