<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 - Akses Ditolak</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
    <style>
        body { background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .error-card { max-width: 500px; text-align: center; padding: 3rem; border-radius: 1rem; }
    </style>
</head>
<body>
    <div class="card error-card shadow-lg">
        <i class="bi bi-shield-x text-danger" style="font-size: 5rem;"></i>
        <h1 class="display-4 mt-3">403</h1>
        <h4>Akses Ditolak</h4>
        <p class="text-muted">Anda tidak memiliki izin untuk mengakses halaman ini.</p>
        <a href="../index.jsp" class="btn btn-primary mt-3">
            <i class="bi bi-house me-2"></i>Kembali ke Beranda
        </a>
    </div>
</body>
</html>
