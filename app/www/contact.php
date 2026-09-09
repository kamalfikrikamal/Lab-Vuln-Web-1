<?php
$pageTitle = 'Kontak';
$sent = isset($_POST['message']) && trim((string) $_POST['message']) !== '';
include __DIR__ . '/includes/header.php';
?>

<h1>Hubungi Kami</h1>

<div class="grid-2">
  <div class="card">
    <?php if ($sent): ?>
      <div class="alert alert-success">Terima kasih, pesan Anda telah kami terima. Tim kami akan segera merespons.</div>
    <?php endif; ?>
    <form method="post" action="contact.php">
      <label for="name">Nama</label>
      <input type="text" id="name" name="name" required>
      <label for="email">Email</label>
      <input type="email" id="email" name="email" required>
      <label for="message">Pesan</label>
      <textarea id="message" name="message" rows="5" required></textarea>
      <button type="submit">Kirim Pesan</button>
    </form>
  </div>
  <div class="card">
    <h3>Kantor Pusat</h3>
    <p class="muted">Jl. Raya Logistik No. 100<br>Jakarta Timur, DKI Jakarta</p>
    <h3>Telepon</h3>
    <p class="muted">(021) 550-1234</p>
    <h3>Email</h3>
    <p class="muted">cs@nusalog.co.id</p>
    <h3>Jam Operasional</h3>
    <p class="muted">Senin - Sabtu, 08.00 - 20.00 WIB</p>
  </div>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
