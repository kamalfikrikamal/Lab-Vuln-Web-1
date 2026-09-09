<?php
require __DIR__ . '/includes/db.php';
require __DIR__ . '/includes/auth.php';
$customer = nusalog_require_customer_login();

/*
 * AMAN (sengaja jadi kontras dengan track.php): query di-scope ke
 * customer_id milik sesi yang sedang login, kolom dipilih eksplisit
 * (tidak menyertakan internal_remarks), dan pakai prepared statement.
 */
$conn = nusalog_db();
$stmt = $conn->prepare(
    'SELECT tracking_id, recipient_name, recipient_city, package_description, status, created_at
     FROM shipments WHERE customer_id = ? ORDER BY created_at DESC'
);
$stmt->bind_param('i', $customer['id']);
$stmt->execute();
$shipments = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
$stmt->close();

$pageTitle = 'Dashboard';
include __DIR__ . '/includes/header.php';
?>

<h1>Halo, <?= htmlspecialchars($customer['name']) ?></h1>
<p class="muted">Berikut riwayat pengiriman yang terdaftar pada akun Anda.</p>

<div class="card">
  <table>
    <thead>
      <tr><th>No. Resi</th><th>Penerima</th><th>Kota Tujuan</th><th>Deskripsi</th><th>Status</th></tr>
    </thead>
    <tbody>
      <?php foreach ($shipments as $s): ?>
        <tr>
          <td><?= htmlspecialchars((string) $s['tracking_id']) ?></td>
          <td><?= htmlspecialchars($s['recipient_name']) ?></td>
          <td><?= htmlspecialchars($s['recipient_city']) ?></td>
          <td><?= htmlspecialchars($s['package_description']) ?></td>
          <td><span class="status-pill status-<?= htmlspecialchars($s['status']) ?>"><?= htmlspecialchars($s['status']) ?></span></td>
        </tr>
      <?php endforeach; ?>
      <?php if (!$shipments): ?>
        <tr><td colspan="5" class="muted">Belum ada riwayat pengiriman.</td></tr>
      <?php endif; ?>
    </tbody>
  </table>
</div>

<p><a href="logout.php">Keluar</a></p>

<?php include __DIR__ . '/includes/footer.php'; ?>
