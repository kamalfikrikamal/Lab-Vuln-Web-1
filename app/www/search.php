<?php
require __DIR__ . '/includes/db.php';
require __DIR__ . '/includes/sanitize.php';

$conn = nusalog_db();
$q = trim((string) ($_GET['q'] ?? ''));
$results = [];
$dbError = false;

if ($q !== '') {
    $qFiltered = nusalog_filter_input($q);

    /*
     * TIDAK memakai prepared statement - input yang sudah "difilter" langsung
     * dirangkai ke query. Developer internal menganggap nusalog_filter_input()
     * cukup untuk mencegah SQL injection karena sudah membuang kata kunci
     * berbahaya. Query sengaja dirancang wildcard di DEPAN nilai ('%$q') agar
     * setelah nilai input tidak ada lagi teks tambahan selain satu tanda kutip
     * penutup - detail kecil ini penting untuk exploitability injeksi di sini.
     */
    $sql = "SELECT tracking_id, sender_name, recipient_name, recipient_city, status
            FROM shipments WHERE recipient_name LIKE '%$qFiltered'";

    $result = $conn->query($sql);
    if ($result) {
        $results = $result->fetch_all(MYSQLI_ASSOC);
    } else {
        $dbError = true;
    }
}

$pageTitle = 'Pencarian Pengiriman';
include __DIR__ . '/includes/header.php';
?>

<h1>Pencarian Pengiriman</h1>
<div class="card" style="max-width:520px;">
  <form method="get" action="search.php">
    <label for="q">Nama Penerima</label>
    <input type="text" id="q" name="q" placeholder="Contoh: Rina Wati" value="<?= htmlspecialchars($q) ?>">
    <button type="submit">Cari</button>
  </form>
</div>

<?php if ($dbError): ?>
  <div class="alert alert-error">Terjadi kesalahan saat memproses pencarian.</div>
<?php elseif ($q !== ''): ?>
  <div class="card">
    <table>
      <thead><tr><th>No. Resi</th><th>Pengirim</th><th>Penerima</th><th>Kota</th><th>Status</th></tr></thead>
      <tbody>
        <?php foreach ($results as $r): ?>
          <tr>
            <td><?= htmlspecialchars((string) $r['tracking_id']) ?></td>
            <td><?= htmlspecialchars((string) $r['sender_name']) ?></td>
            <td><?= htmlspecialchars((string) $r['recipient_name']) ?></td>
            <td><?= htmlspecialchars((string) $r['recipient_city']) ?></td>
            <td><?= htmlspecialchars((string) $r['status']) ?></td>
          </tr>
        <?php endforeach; ?>
        <?php if (!$results): ?>
          <tr><td colspan="5" class="muted">Tidak ada hasil ditemukan.</td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
