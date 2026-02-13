<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("../LoginServlet");
        return;
    }
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    String csrfToken = (String) session.getAttribute("csrfToken");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pengaturan - Examora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
    <style>
        .settings-sidebar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: calc(100vh - 56px);
        }
        .settings-sidebar .nav-link {
            color: rgba(255,255,255,0.8);
            padding: 1rem 1.5rem;
            border-radius: 8px;
            margin: 4px 0;
            transition: all 0.3s;
        }
        .settings-sidebar .nav-link:hover,
        .settings-sidebar .nav-link.active {
            background: rgba(255,255,255,0.2);
            color: #fff;
        }
        .settings-sidebar .nav-link i {
            width: 24px;
            margin-right: 10px;
        }
        .profile-photo-container {
            position: relative;
            width: 150px;
            height: 150px;
            margin: 0 auto;
        }
        .profile-photo {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #fff;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        .profile-photo-placeholder {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            border: 4px solid #fff;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        .profile-photo-placeholder i {
            font-size: 4rem;
            color: rgba(255,255,255,0.8);
        }
        .photo-upload-btn {
            position: absolute;
            bottom: 5px;
            right: 5px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .photo-upload-btn:hover {
            transform: scale(1.1);
        }
        .settings-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        }
        .settings-card .card-header {
            background: transparent;
            border-bottom: 1px solid #eee;
            padding: 1.25rem 1.5rem;
        }
        .form-floating > label {
            color: #6c757d;
        }
        .password-strength {
            height: 4px;
            border-radius: 2px;
            margin-top: 8px;
            transition: all 0.3s;
        }
        .password-strength.weak { background: #dc3545; width: 33%; }
        .password-strength.medium { background: #ffc107; width: 66%; }
        .password-strength.strong { background: #198754; width: 100%; }
        @media (max-width: 767.98px) {
            .settings-sidebar {
                min-height: auto;
            }
            .settings-sidebar .nav-link {
                padding: 0.75rem 1rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand fw-bold" href="<%= user.isAdmin() ? "../AdminServlet?action=dashboard" : "../ExamServlet?action=dashboard" %>">
                <i class="bi bi-journal-check me-2"></i>Examora
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="<%= user.isAdmin() ? "../AdminServlet?action=dashboard" : "../ExamServlet?action=dashboard" %>">
                            <i class="bi bi-house me-1"></i>Dashboard
                        </a>
                    </li>
                </ul>
                <div class="d-flex align-items-center">
                    <a href="../SettingsServlet" class="text-white text-decoration-none me-3">
                        <i class="bi bi-person-circle me-1"></i><%= user.getName() %>
                    </a>
                    <a href="../LogoutServlet" class="btn btn-outline-light btn-sm">
                        <i class="bi bi-box-arrow-left me-1"></i>Logout
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-md-3 col-lg-2 settings-sidebar p-0">
                <div class="p-3">
                    <h6 class="text-white-50 text-uppercase small mb-3 px-3">Pengaturan</h6>
                    <nav class="nav flex-column">
                        <a class="nav-link active" href="#profile-section" data-bs-toggle="tab">
                            <i class="bi bi-person"></i>Profil
                        </a>
                        <a class="nav-link" href="#password-section" data-bs-toggle="tab">
                            <i class="bi bi-key"></i>Password
                        </a>
                        <a class="nav-link" href="#photo-section" data-bs-toggle="tab">
                            <i class="bi bi-image"></i>Foto Profil
                        </a>
                    </nav>
                </div>
            </div>

            <!-- Main Content -->
            <div class="col-md-9 col-lg-10 py-4 px-4 px-md-5">
                <!-- Alert Messages -->
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

                <div class="tab-content">
                    <!-- Profile Section -->
                    <div class="tab-pane fade show active" id="profile-section">
                        <div class="settings-card card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="bi bi-person me-2"></i>Informasi Profil</h5>
                            </div>
                            <div class="card-body p-4">
                                <form action="../SettingsServlet" method="post" enctype="multipart/form-data" id="profileForm">
                                    <input type="hidden" name="action" value="updateProfile">
                                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

                                    <div class="row mb-4">
                                        <div class="col-md-3 text-center mb-3 mb-md-0">
                                            <% if (user.getPhoto() != null && !user.getPhoto().isEmpty()) { %>
                                            <img src="../<%= user.getPhoto() %>" alt="Profile" class="profile-photo">
                                            <% } else { %>
                                            <div class="profile-photo-placeholder mx-auto">
                                                <i class="bi bi-person"></i>
                                            </div>
                                            <% } %>
                                        </div>
                                        <div class="col-md-9">
                                            <div class="mb-3">
                                                <label for="name" class="form-label">Nama Lengkap</label>
                                                <input type="text" class="form-control form-control-lg" id="name" name="name"
                                                       value="<%= user.getName() %>" required
                                                       placeholder="Masukkan nama lengkap">
                                            </div>
                                            <div class="mb-3">
                                                <label for="email" class="form-label">Email</label>
                                                <input type="email" class="form-control form-control-lg" id="email" name="email"
                                                       value="<%= user.getEmail() %>" required
                                                       placeholder="Masukkan email">
                                            </div>
                                            <div class="row">
                                                <div class="col-md-6 mb-3 mb-md-0">
                                                    <label class="form-label">Role</label>
                                                    <input type="text" class="form-control" value="<%= user.isAdmin() ? "Administrator" : "Peserta" %>" disabled>
                                                </div>
                                                <div class="col-md-6">
                                                    <label class="form-label">Tag/Kelompok</label>
                                                    <input type="text" class="form-control" value="<%= user.getTag() != null ? user.getTag() : "-" %>" disabled>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label for="photo" class="form-label">Ganti Foto Profil (opsional)</label>
                                        <input type="file" class="form-control" id="photo" name="photo"
                                               accept="image/jpeg,image/png,image/gif,image/webp">
                                        <div class="form-text">Format: JPG, PNG, GIF, WEBP. Maksimal 2MB.</div>
                                    </div>

                                    <div class="d-flex gap-2">
                                        <button type="submit" class="btn btn-primary btn-lg">
                                            <i class="bi bi-check-lg me-2"></i>Simpan Perubahan
                                        </button>
                                        <a href="<%= user.isAdmin() ? "../AdminServlet?action=dashboard" : "../ExamServlet?action=dashboard" %>"
                                           class="btn btn-outline-secondary btn-lg">
                                            <i class="bi bi-arrow-left me-2"></i>Kembali
                                        </a>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Password Section -->
                    <div class="tab-pane fade" id="password-section">
                        <div class="settings-card card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="bi bi-key me-2"></i>Ubah Password</h5>
                            </div>
                            <div class="card-body p-4">
                                <form action="../SettingsServlet" method="post" id="passwordForm">
                                    <input type="hidden" name="action" value="changePassword">
                                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

                                    <div class="mb-4">
                                        <label for="currentPassword" class="form-label">Password Saat Ini</label>
                                        <div class="input-group input-group-lg">
                                            <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                            <input type="password" class="form-control" id="currentPassword" name="currentPassword"
                                                   required placeholder="Masukkan password saat ini">
                                            <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('currentPassword')">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="mb-4">
                                        <label for="newPassword" class="form-label">Password Baru</label>
                                        <div class="input-group input-group-lg">
                                            <span class="input-group-text"><i class="bi bi-key"></i></span>
                                            <input type="password" class="form-control" id="newPassword" name="newPassword"
                                                   required placeholder="Masukkan password baru"
                                                   oninput="checkPasswordStrength(this.value)">
                                            <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('newPassword')">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                        <div class="password-strength mt-2" id="passwordStrength"></div>
                                        <div class="form-text" id="passwordHint">Minimal 6 karakter. Disarankan kombinasi huruf, angka, dan simbol.</div>
                                    </div>

                                    <div class="mb-4">
                                        <label for="confirmPassword" class="form-label">Konfirmasi Password Baru</label>
                                        <div class="input-group input-group-lg">
                                            <span class="input-group-text"><i class="bi bi-check2-lock"></i></span>
                                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword"
                                                   required placeholder="Ulangi password baru">
                                            <button class="btn btn-outline-secondary" type="button" onclick="togglePassword('confirmPassword')">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                        </div>
                                        <div class="form-text" id="matchStatus"></div>
                                    </div>

                                    <button type="submit" class="btn btn-primary btn-lg">
                                        <i class="bi bi-key me-2"></i>Ubah Password
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Photo Section -->
                    <div class="tab-pane fade" id="photo-section">
                        <div class="settings-card card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="bi bi-image me-2"></i>Foto Profil</h5>
                            </div>
                            <div class="card-body p-4 text-center">
                                <div class="profile-photo-container mb-4">
                                    <% if (user.getPhoto() != null && !user.getPhoto().isEmpty()) { %>
                                    <img src="../<%= user.getPhoto() %>" alt="Profile" class="profile-photo" id="previewPhoto">
                                    <% } else { %>
                                    <div class="profile-photo-placeholder" id="previewPlaceholder">
                                        <i class="bi bi-person"></i>
                                    </div>
                                    <% } %>
                                </div>

                                <form action="../SettingsServlet" method="post" enctype="multipart/form-data" id="photoForm">
                                    <input type="hidden" name="action" value="updatePhoto">
                                    <input type="hidden" name="csrfToken" value="<%= csrfToken %>">

                                    <div class="mb-4">
                                        <label for="photoOnly" class="btn btn-outline-primary btn-lg">
                                            <i class="bi bi-upload me-2"></i>Pilih Foto
                                        </label>
                                        <input type="file" class="d-none" id="photoOnly" name="photo"
                                               accept="image/jpeg,image/png,image/gif,image/webp"
                                               onchange="previewImage(this)">
                                        <div class="form-text mt-2">Format: JPG, PNG, GIF, WEBP. Maksimal 2MB.</div>
                                    </div>

                                    <div id="previewContainer" class="mb-4 d-none">
                                        <p class="text-muted">Preview:</p>
                                        <img id="imagePreview" src="" alt="Preview" class="rounded shadow" style="max-width: 200px; max-height: 200px;">
                                    </div>

                                    <button type="submit" class="btn btn-primary btn-lg" id="uploadBtn" disabled>
                                        <i class="bi bi-check-lg me-2"></i>Upload Foto
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Tab navigation
        document.querySelectorAll('.settings-sidebar .nav-link').forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                document.querySelectorAll('.settings-sidebar .nav-link').forEach(l => l.classList.remove('active'));
                this.classList.add('active');

                const target = this.getAttribute('href');
                document.querySelectorAll('.tab-pane').forEach(pane => {
                    pane.classList.remove('show', 'active');
                });
                document.querySelector(target).classList.add('show', 'active');
            });
        });

        // Toggle password visibility
        function togglePassword(fieldId) {
            const field = document.getElementById(fieldId);
            const button = field.nextElementSibling;
            const icon = button.querySelector('i');

            if (field.type === 'password') {
                field.type = 'text';
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
            } else {
                field.type = 'password';
                icon.classList.remove('bi-eye-slash');
                icon.classList.add('bi-eye');
            }
        }

        // Password strength checker
        function checkPasswordStrength(password) {
            const strengthBar = document.getElementById('passwordStrength');
            const hint = document.getElementById('passwordHint');

            if (password.length === 0) {
                strengthBar.className = 'password-strength';
                hint.textContent = 'Minimal 6 karakter. Disarankan kombinasi huruf, angka, dan simbol.';
                return;
            }

            let strength = 0;
            if (password.length >= 6) strength++;
            if (password.length >= 10) strength++;
            if (/[A-Z]/.test(password) && /[a-z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;

            if (strength <= 2) {
                strengthBar.className = 'password-strength weak';
                hint.textContent = 'Password lemah. Tambahkan huruf besar, angka, atau simbol.';
            } else if (strength <= 3) {
                strengthBar.className = 'password-strength medium';
                hint.textContent = 'Password sedang. Pertimbangkan untuk menambah kompleksitas.';
            } else {
                strengthBar.className = 'password-strength strong';
                hint.textContent = 'Password kuat!';
            }

            // Check confirmation match
            checkPasswordMatch();
        }

        // Check password match
        function checkPasswordMatch() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const matchStatus = document.getElementById('matchStatus');

            if (confirmPassword.length === 0) {
                matchStatus.textContent = '';
                return;
            }

            if (newPassword === confirmPassword) {
                matchStatus.innerHTML = '<span class="text-success"><i class="bi bi-check-circle me-1"></i>Password cocok</span>';
            } else {
                matchStatus.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle me-1"></i>Password tidak cocok</span>';
            }
        }

        document.getElementById('confirmPassword').addEventListener('input', checkPasswordMatch);

        // Image preview
        function previewImage(input) {
            const previewContainer = document.getElementById('previewContainer');
            const imagePreview = document.getElementById('imagePreview');
            const uploadBtn = document.getElementById('uploadBtn');

            if (input.files && input.files[0]) {
                const file = input.files[0];

                // Validate file size (2MB)
                if (file.size > 2 * 1024 * 1024) {
                    alert('Ukuran file maksimal 2MB');
                    input.value = '';
                    previewContainer.classList.add('d-none');
                    uploadBtn.disabled = true;
                    return;
                }

                // Validate file type
                const validTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
                if (!validTypes.includes(file.type)) {
                    alert('Format file tidak didukung. Gunakan JPG, PNG, GIF, atau WEBP.');
                    input.value = '';
                    previewContainer.classList.add('d-none');
                    uploadBtn.disabled = true;
                    return;
                }

                const reader = new FileReader();
                reader.onload = function(e) {
                    imagePreview.src = e.target.result;
                    previewContainer.classList.remove('d-none');
                    uploadBtn.disabled = false;
                };
                reader.readAsDataURL(file);
            } else {
                previewContainer.classList.add('d-none');
                uploadBtn.disabled = true;
            }
        }

        // Form validation
        document.getElementById('profileForm').addEventListener('submit', function(e) {
            const name = document.getElementById('name').value.trim();
            const email = document.getElementById('email').value.trim();

            if (!name) {
                e.preventDefault();
                alert('Nama tidak boleh kosong');
                return;
            }

            if (!email || !email.includes('@')) {
                e.preventDefault();
                alert('Email tidak valid');
                return;
            }
        });

        document.getElementById('passwordForm').addEventListener('submit', function(e) {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            if (newPassword !== confirmPassword) {
                e.preventDefault();
                alert('Konfirmasi password tidak cocok');
                return;
            }

            if (newPassword.length < 6) {
                e.preventDefault();
                alert('Password baru minimal 6 karakter');
                return;
            }
        });
    </script>
</body>
</html>
