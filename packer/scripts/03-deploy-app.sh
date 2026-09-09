#!/bin/bash
set -euxo pipefail

APP_PORT="${APP_PORT:-8082}"
APP_ROOT="/var/www/nusalog"

rm -rf "$APP_ROOT"
mkdir -p "$APP_ROOT"
cp -r /tmp/app-src/. "$APP_ROOT"/
chown -R www-data:www-data "$APP_ROOT"
find "$APP_ROOT" -type d -exec chmod 755 {} \;
find "$APP_ROOT" -type f -exec chmod 644 {} \;

# Listen di port non-standar, di samping port default yang sudah ada.
if ! grep -q "Listen ${APP_PORT}" /etc/apache2/ports.conf; then
  echo "Listen ${APP_PORT}" >> /etc/apache2/ports.conf
fi

cat > /etc/apache2/sites-available/nusalog.conf <<EOF
<VirtualHost *:${APP_PORT}>
    ServerName nusalog.local
    DocumentRoot ${APP_ROOT}

    <Directory ${APP_ROOT}>
        Options -Indexes -FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/nusalog-error.log
    CustomLog \${APACHE_LOG_DIR}/nusalog-access.log combined
</VirtualHost>
EOF

a2dissite 000-default >/dev/null 2>&1 || true
a2ensite nusalog

# Sembunyikan versi Apache/PHP dan matikan display_errors di production.
sed -i 's/^ServerTokens.*/ServerTokens Prod/' /etc/apache2/conf-available/security.conf || true
sed -i 's/^ServerSignature.*/ServerSignature Off/' /etc/apache2/conf-available/security.conf || true

PHP_INI=$(php -i | awk -F' => ' '/Loaded Configuration File/{print $2}')
if [ -n "$PHP_INI" ] && [ -f "$PHP_INI" ]; then
  sed -i 's/^display_errors\s*=.*/display_errors = Off/' "$PHP_INI"
  sed -i 's/^expose_php\s*=.*/expose_php = Off/' "$PHP_INI"
fi

systemctl restart apache2
