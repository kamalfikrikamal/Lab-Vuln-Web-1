<?php
require __DIR__ . '/includes/db.php';
require __DIR__ . '/includes/auth.php';
nusalog_start_session();

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim((string) ($_POST['email'] ?? ''));
    $password = (string) ($_POST['password'] ?? '');

    $customer = nusalog_customer_login(nusalog_db(), $email, $password);
    if ($customer) {
        $_SESSION['customer_id'] = $customer['id'];
        $_SESSION['customer_name'] = $customer['full_name'];
        header('Location: dashboard.php');
        exit;
    }
    $error = 'Email atau kata sandi salah.';
}

$pageTitle = 'Login Pelanggan';
include __DIR__ . '/includes/header.php';
?>

<h1>Login Pelanggan</h1>
<div class="card" style="max-width:420px;">
  <?php if ($error): ?>
    <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
  <?php endif; ?>
  <form method="post" action="login.php">
    <label for="email">Email</label>
    <input type="email" id="email" name="email" required autofocus>
    <label for="password">Kata Sandi</label>
    <input type="password" id="password" name="password" required>
    <button type="submit">Masuk</button>
  </form>
  <p class="muted" style="margin-top:16px;">Belum punya akun? Hubungi customer service kami untuk pendaftaran pengiriman rutin.</p>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
