<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
if (empty($_SESSION['staff_id'])) {
    header('Location: login.php');
    exit;
}
?>
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>Dashboard Staff - NusaLog</title>
  <link rel="stylesheet" href="../assets/css/style.css">
  <meta name="robots" content="noindex, nofollow">
</head>
<body>
<main class="wrap" style="padding-top:48px;max-width:640px;">
  <h1>Dashboard Staff</h1>
  <p class="muted">Selamat datang, <?= htmlspecialchars($_SESSION['staff_name'] ?? 'Staff') ?> (<?= htmlspecialchars($_SESSION['staff_role'] ?? '') ?>)</p>

  <div class="card">
    <h3>Cek Status Kurir</h3>
    <p class="muted">Tool internal untuk memeriksa konektivitas jaringan ke server mitra kurir sebelum dispatch pengiriman kargo besar.</p>
    <a class="btn" href="courier-check.php">Buka Tool</a>
  </div>

  <p><a href="logout.php">Keluar</a></p>
</main>
</body>
</html>
