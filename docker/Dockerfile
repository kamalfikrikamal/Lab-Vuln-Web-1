# Image deployment lab NusaLog: Apache+PHP+MySQL+sudo misconfig dalam satu
# container - tanpa systemd (memakai `service ...`), tanpa Packer/VPS
# provisioning terpisah.
#
# Jalankan (dari root repo, di VPS mana pun yang sudah punya Docker):
#   docker compose up -d --build
# Aplikasi lalu bisa diakses di http://<ip-vps>:8095
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV APP_PORT=8095

RUN apt-get update && apt-get install -y \
      apache2 php php-mysql php-mbstring libapache2-mod-php \
      mysql-server sudo less curl \
    && rm -rf /var/lib/apt/lists/*

COPY app/www /tmp/app-src
COPY app/sql /tmp/sql

RUN rm -rf /var/www/nusalog && mkdir -p /var/www/nusalog \
    && cp -r /tmp/app-src/. /var/www/nusalog/ \
    && chown -R www-data:www-data /var/www/nusalog \
    && find /var/www/nusalog -type d -exec chmod 755 {} \; \
    && find /var/www/nusalog -type f -exec chmod 644 {} \;

RUN echo "Listen ${APP_PORT}" >> /etc/apache2/ports.conf \
    && printf '<VirtualHost *:%s>\n    ServerName nusalog.local\n    DocumentRoot /var/www/nusalog\n    <Directory /var/www/nusalog>\n        Options -Indexes -FollowSymLinks\n        AllowOverride None\n        Require all granted\n    </Directory>\n</VirtualHost>\n' "${APP_PORT}" > /etc/apache2/sites-available/nusalog.conf \
    && a2dissite 000-default \
    && a2ensite nusalog

# VULNERABILITAS (privesc www-data -> root): rule sudo ini dimaksudkan agar
# aplikasi/staff bisa meninjau log Apache tanpa akses root penuh. Masalahnya,
# /usr/bin/less punya fitur shell-escape bawaan ("!perintah" atau "!/bin/sh"
# saat sedang membuka file lewat pager) yang tidak dibatasi oleh sudo -
# sehingga siapa pun yang mendapat shell sebagai www-data bisa memakai rule
# ini untuk mendapatkan shell root (lihat GTFOBins: less).
RUN echo 'www-data ALL=(root) NOPASSWD: /usr/bin/less /var/log/apache2/*.log' > /etc/sudoers.d/www-data-logs \
    && chmod 0440 /etc/sudoers.d/www-data-logs \
    && visudo -c -f /etc/sudoers.d/www-data-logs

# Flag bukti keberhasilan privilege escalation ke root. Diletakkan langsung
# di home root (bukan disembunyikan/di-hide) agar peserta yang sudah berhasil
# eksploitasi rantai kerentanan tidak perlu mencarinya lagi.
RUN echo "NUSALOG{r00t_via_l3ss_gtf0bins_sudo_misconfig}" > /root/flag.txt \
    && chmod 0400 /root/flag.txt \
    && chown root:root /root/flag.txt

EXPOSE 8095

CMD service mysql start \
    && chmod 755 /var/run/mysqld \
    && mysql -uroot -e "SOURCE /tmp/sql/schema.sql; SOURCE /tmp/sql/seed.sql; \
         CREATE USER IF NOT EXISTS 'nusalog_app'@'localhost' IDENTIFIED BY 'N0nAdm1nApp!23'; \
         GRANT SELECT, INSERT, UPDATE ON nusalog.* TO 'nusalog_app'@'localhost'; FLUSH PRIVILEGES;" \
    && service apache2 start \
    && tail -f /var/log/apache2/*.log
