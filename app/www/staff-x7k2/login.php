<?php
require __DIR__ . '/../includes/db.php';
require __DIR__ . '/../includes/sanitize.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
if (!empty($_SESSION['staff_id'])) {
    header('Location: dashboard.php');
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $conn = nusalog_db();
    $username = nusalog_filter_input(trim((string) ($_POST['username'] ?? '')));
    $password = (string) ($_POST['password'] ?? '');

    /*
     * Sama seperti search.php: query dirangkai manual, mengandalkan
     * nusalog_filter_input() sebagai satu-satunya lapisan pertahanan.
     * Password TIDAK ikut masuk ke query - dicocokkan lewat password_verify()
     * di PHP setelah baris ditemukan berdasarkan username. Developer internal
     * menganggap ini "lebih aman" karena tidak menaruh hash di query, padahal
     * titik rawannya tetap ada di kolom username yang tidak di-parameterize.
     */
    $sql = "SELECT id, username, full_name, role, password_hash
            FROM staff WHERE username = '$username'";

    $result = $conn->query($sql);
    $row = $result ? $result->fetch_assoc() : null;

    if ($row && password_verify($password, $row['password_hash'])) {
        $_SESSION['staff_id'] = $row['id'];
        $_SESSION['staff_name'] = $row['full_name'];
        $_SESSION['staff_role'] = $row['role'];
        header('Location: dashboard.php');
        exit;
    }
    $error = 'Username atau kata sandi salah.';
}
?>
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>Portal Internal - NusaLog</title>
  <link rel="stylesheet" href="../assets/css/style.css">
  <meta name="robots" content="noindex, nofollow">
</head>
<body>
<main class="wrap" style="padding-top:64px;max-width:420px;">
  <h1>Portal Internal Staff</h1>
  <p class="muted">Akses terbatas untuk karyawan PT Nusantara Logistik.</p>
  <div class="card">
    <?php if ($error): ?>
      <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>
    <form method="post" action="login.php">
      <label for="username">Username</label>
      <input type="text" id="username" name="username" required autofocus>
      <label for="password">Kata Sandi</label>
      <input type="password" id="password" name="password" required>
      <button type="submit">Masuk</button>
    </form>
  </div>
</main>
</body>
</html>
