<?php
require __DIR__ . '/includes/db.php';

$conn = nusalog_db();
$trackingId = $_GET['tracking_id'] ?? '';
$shipment = null;
$notFound = false;

if ($trackingId !== '') {
    /*
     * Query ini sudah pakai prepared statement (aman dari SQL injection),
     * TAPI tidak ada pengecekan kepemilikan sama sekali - siapa pun yang
     * tahu/menebak nomor resi (yang berupa integer berurutan) bisa melihat
     * detail lengkap pengiriman customer lain. SELECT * juga ikut membawa
     * kolom internal_remarks yang seharusnya tidak untuk konsumsi publik.
     */
    $stmt = $conn->prepare('SELECT * FROM shipments WHERE tracking_id = ? LIMIT 1');
    $stmt->bind_param('i', $trackingId);
    $stmt->execute();
    $shipment = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    $notFound = !$shipment;
}

$pageTitle = 'Lacak Kiriman';
include __DIR__ . '/includes/header.php';
?>

<h1>Lacak Kiriman</h1>
<div class="card" style="max-width:520px;">
  <form method="get" action="track.php">
    <label for="tracking_id">Nomor Resi</label>
    <input type="text" id="tracking_id" name="tracking_id" placeholder="Contoh: 100001" value="<?= htmlspecialchars((string) $trackingId) ?>" required>
    <button type="submit">Lacak</button>
  </form>
  <p class="muted" style="margin-top:14px;">Mencari berdasarkan nama penerima atau kota tujuan? Gunakan <a href="search.php">pencarian pengiriman</a>.</p>
</div>

<?php if ($notFound): ?>
  <div class="alert alert-error">Nomor resi tidak ditemukan.</div>
<?php elseif ($shipment): ?>
  <div class="card">
    <h2>Resi #<?= htmlspecialchars((string) $shipment['tracking_id']) ?></h2>
    <span class="status-pill status-<?= htmlspecialchars($shipment['status']) ?>"><?= htmlspecialchars($shipment['status']) ?></span>
    <table style="margin-top:16px;">
      <tr><th>Pengirim</th><td><?= htmlspecialchars($shipment['sender_name']) ?></td></tr>
      <tr><th>Alamat Asal</th><td><?= htmlspecialchars($shipment['sender_address']) ?></td></tr>
      <tr><th>Penerima</th><td><?= htmlspecialchars($shipment['recipient_name']) ?></td></tr>
      <tr><th>Alamat Tujuan</th><td><?= htmlspecialchars($shipment['recipient_address']) ?>, <?= htmlspecialchars($shipment['recipient_city']) ?></td></tr>
      <tr><th>Deskripsi Paket</th><td><?= htmlspecialchars($shipment['package_description']) ?></td></tr>
      <tr><th>Berat</th><td><?= htmlspecialchars((string) $shipment['weight_kg']) ?> kg</td></tr>
      <tr><th>Kurir</th><td><?= htmlspecialchars($shipment['courier']) ?></td></tr>
      <?php if (!empty($shipment['internal_remarks'])): ?>
        <tr><th>Catatan</th><td><?= htmlspecialchars($shipment['internal_remarks']) ?></td></tr>
      <?php endif; ?>
    </table>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
