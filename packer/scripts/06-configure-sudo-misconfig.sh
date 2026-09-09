#!/bin/bash
set -euxo pipefail

# VULNERABILITAS (privesc www-data -> root): rule sudo ini dimaksudkan agar
# aplikasi/staff bisa meninjau log Apache tanpa akses root penuh. Masalahnya,
# /usr/bin/less punya fitur shell-escape bawaan ("!perintah" atau "!/bin/sh"
# saat sedang membuka file lewat pager) yang tidak dibatasi oleh sudo -
# sehingga siapa pun yang mendapat shell sebagai www-data bisa memakai rule
# ini untuk mendapatkan shell root (lihat GTFOBins: less).
SUDOERS_FILE="/etc/sudoers.d/www-data-logs"

cat > "$SUDOERS_FILE" <<'EOF'
# Izinkan www-data meninjau log Apache tanpa perlu akses root penuh.
www-data ALL=(root) NOPASSWD: /usr/bin/less /var/log/apache2/*.log
EOF

chmod 0440 "$SUDOERS_FILE"
visudo -c -f "$SUDOERS_FILE"
