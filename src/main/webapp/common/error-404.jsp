<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Halaman Tidak Ditemukan</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="icon" type="image/svg+xml" href="../assets/img/favicon.svg">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .error-card { max-width: 500px; text-align: center; padding: 3rem; border-radius: 1rem; }
    </style>
</head>
<body>
    <div class="card error-card shadow-lg">
        <i class="bi bi-exclamation-triangle text-warning" style="font-size: 5rem;"></i>
        <h1 class="display-4 mt-3">404</h1>
        <h4>Halaman Tidak Ditemukan</h4>
        <p class="text-muted">Halaman yang Anda cari tidak ada atau telah dipindahkan.</p>
        <a href="../index.jsp" class="btn btn-primary mt-3">
            <i class="bi bi-house me-2"></i>Kembali ke Beranda
        </a>
    </div>
</body>
</html>
