<?php
/** Helper sesi login pelanggan (jalur ini AMAN - prepared statement + password_verify). */

function nusalog_start_session(): void
{
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
}

function nusalog_customer_login(mysqli $conn, string $email, string $password): ?array
{
    $stmt = $conn->prepare('SELECT id, full_name, email, password_hash FROM customers WHERE email = ? LIMIT 1');
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result->fetch_assoc();
    $stmt->close();

    if ($row && password_verify($password, $row['password_hash'])) {
        return $row;
    }
    return null;
}

function nusalog_require_customer_login(): array
{
    nusalog_start_session();
    if (empty($_SESSION['customer_id'])) {
        header('Location: login.php');
        exit;
    }
    return [
        'id' => $_SESSION['customer_id'],
        'name' => $_SESSION['customer_name'] ?? '',
    ];
}
