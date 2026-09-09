#!/bin/bash
set -euxo pipefail

DB_NAME="nusalog"
DB_USER="nusalog_app"
DB_PASS="N0nAdm1nApp!23"

# MySQL hanya mendengarkan di localhost - tidak pernah diekspos ke jaringan.
MYSQLD_CNF="/etc/mysql/mysql.conf.d/mysqld.cnf"
if [ -f "$MYSQLD_CNF" ]; then
  sed -i 's/^bind-address.*/bind-address = 127.0.0.1/' "$MYSQLD_CNF"
fi
systemctl restart mysql

# Jaga-jaga: pastikan www-data bisa mengakses socket lewat direktori ini
# (koneksi PHP ke MySQL memakai host "localhost" -> Unix socket).
chmod 755 /var/run/mysqld || true

mysql -uroot <<SQL
SOURCE /tmp/sql/schema.sql;
SOURCE /tmp/sql/seed.sql;

CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
-- Sengaja TANPA hak FILE/SUPER: mencegah jalur privesc via SQLi (mis. INTO OUTFILE)
-- yang tidak dimaksudkan sebagai bagian dari rantai eksploitasi lab ini.
GRANT SELECT, INSERT, UPDATE ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

rm -rf /tmp/sql /tmp/app-src
