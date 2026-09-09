<?php
/**
 * Filter input "keamanan" internal NusaLog.
 *
 * CATATAN DESAIN LAB: fungsi ini SENGAJA cacat untuk skenario latihan pentest.
 * Ia membuang kata kunci berbahaya dalam SATU KALI PASS (str_ireplace),
 * bukan berulang sampai tidak ada perubahan (non-recursive filter). Ini
 * membuatnya rentan terhadap teknik "nested keyword" klasik: kata kunci yang
 * diselipkan di tengah kata kunci itu sendiri akan tersisa utuh setelah satu
 * kali proses penyaringan, karena potongan sisa di kiri+kanan menyatu kembali
 * membentuk kata kunci yang sama persis.
 *
 * Contoh: "SelSELECTect" -> setelah "SELECT" (case-insensitive) di tengah
 * dihapus, sisa "Sel" + "ect" menyatu menjadi "Select" -> tetap valid
 * sebagai keyword SQL (SQL tidak case-sensitive untuk keyword).
 */
function nusalog_filter_input(string $input): string
{
    $blocked = [
        'union', 'select', 'insert', 'update', 'delete', 'drop',
        ' or ', ' and ', '--', '#', '/*', '*/', 'sleep(', 'benchmark(',
    ];

    $clean = $input;
    foreach ($blocked as $word) {
        $clean = str_ireplace($word, '', $clean);
    }

    return $clean;
}
