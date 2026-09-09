<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
if (empty($_SESSION['staff_id'])) {
    header('Location: login.php');
    exit;
}

$output = '';
$host = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $host = trim((string) ($_POST['host'] ?? ''));
    if ($host !== '') {
        /*
         * VULNERABILITAS: input host langsung dirangkai ke perintah shell
         * tanpa escapeshellarg()/escapeshellcmd() dan tanpa whitelist
         * karakter. Siapa pun yang mencapai halaman ini (setelah bypass
         * login staff) bisa menyisipkan operator shell (;, &&, |, `` ` ``,
         * $(...)) untuk menjalankan perintah arbitrer sebagai user www-data.
         */
        $output = shell_exec('ping -c 1 -W 2 ' . $host . ' 2>&1');
    }
}
?>
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <title>Cek Status Kurir - NusaLog</title>
  <link rel="stylesheet" href="../assets/css/style.css">
  <meta name="robots" content="noindex, nofollow">
</head>
<body>
<main class="wrap" style="padding-top:48px;max-width:640px;">
  <h1>Cek Status Kurir</h1>
  <p class="muted">Masukkan host/IP server mitra kurir untuk menguji konektivitas jaringan.</p>

  <div class="card">
    <form method="post" action="courier-check.php">
      <label for="host">Host / IP</label>
      <input type="text" id="host" name="host" placeholder="Contoh: mitra-kurir.local" value="<?= htmlspecialchars($host) ?>" required>
      <button type="submit">Cek Koneksi</button>
    </form>
  </div>

  <?php if ($output !== ''): ?>
    <div class="card">
      <h3>Hasil</h3>
      <pre style="white-space:pre-wrap;background:#0f2c4c;color:#dce8f5;padding:14px;border-radius:6px;overflow-x:auto;"><?= htmlspecialchars($output) ?></pre>
    </div>
  <?php endif; ?>

  <p><a href="dashboard.php">&larr; Kembali</a></p>
</main>
</body>
</html>
