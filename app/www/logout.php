<?php
require __DIR__ . '/includes/auth.php';
nusalog_start_session();
$_SESSION = [];
session_destroy();
header('Location: login.php');
exit;
