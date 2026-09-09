<?php
/**
 * Koneksi database NusaLog. Kredensial default cocok dengan yang dipasang
 * oleh packer/scripts/04-configure-mysql.sh (user aplikasi low-privilege,
 * tanpa hak FILE/SUPER). Bisa dioverride lewat environment variable untuk
 * pengujian lokal (mis. docker/Dockerfile.dev).
 */
function nusalog_db(): mysqli
{
    static $conn = null;
    if ($conn !== null) {
        return $conn;
    }

    $host = getenv('NUSALOG_DB_HOST') ?: 'localhost';
    $port = (int) (getenv('NUSALOG_DB_PORT') ?: 3306);
    $name = getenv('NUSALOG_DB_NAME') ?: 'nusalog';
    $user = getenv('NUSALOG_DB_USER') ?: 'nusalog_app';
    $pass = getenv('NUSALOG_DB_PASS') ?: 'N0nAdm1nApp!23';

    mysqli_report(MYSQLI_REPORT_OFF);
    $conn = mysqli_connect($host, $user, $pass, $name, $port);
    if (!$conn) {
        http_response_code(500);
        exit('Layanan sedang tidak tersedia. Silakan coba lagi nanti.');
    }
    $conn->set_charset('utf8mb4');

    return $conn;
}
