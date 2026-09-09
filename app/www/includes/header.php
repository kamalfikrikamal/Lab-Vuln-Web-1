<?php $current = basename($_SERVER['PHP_SELF']); ?>
<!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><?= isset($pageTitle) ? htmlspecialchars($pageTitle) . ' - ' : '' ?>PT Nusantara Logistik</title>
  <link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<header class="site-header">
  <div class="wrap">
    <a class="brand" href="index.php">NusaLog<span>.</span></a>
    <nav>
      <a href="index.php" class="<?= $current === 'index.php' ? 'active' : '' ?>">Beranda</a>
      <a href="services.php" class="<?= $current === 'services.php' ? 'active' : '' ?>">Layanan</a>
      <a href="track.php" class="<?= $current === 'track.php' ? 'active' : '' ?>">Lacak Kiriman</a>
      <a href="about.php" class="<?= $current === 'about.php' ? 'active' : '' ?>">Tentang Kami</a>
      <a href="contact.php" class="<?= $current === 'contact.php' ? 'active' : '' ?>">Kontak</a>
      <a href="login.php" class="cta <?= $current === 'login.php' ? 'active' : '' ?>">Login Pelanggan</a>
    </nav>
  </div>
</header>
<main class="wrap">
