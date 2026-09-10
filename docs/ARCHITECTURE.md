# Arsitektur Lab NusaLog

## Gambaran Umum

Satu container Docker (`docker compose up -d --build`, lihat `docker/Dockerfile`)
yang jalan di VPS mana pun, berisi website perusahaan logistik fiktif
"PT Nusantara Logistik" dengan kerentanan yang disengaja untuk latihan
pentest (bukan CTF flag-based - peserta melaporkan temuan, bukan mengejar
flag).

```
Peserta (laptop mana pun, via internet)
        |
        | nmap -p-
        v
+-----------------------------------+
|  VPS (host Docker)                 |
|                                     |
|  8095/tcp -> container nusalog     |  <- port non-standar, di luar top-1000 nmap
|    - Apache (NusaLog web)          |
|    - MySQL: localhost/socket saja  |
|      di dalam container (tidak     |
|      dipublish ke host)            |
+-----------------------------------+
```

Root shell yang jadi tujuan akhir rantai eksploitasi adalah root **di dalam
container**, bukan root host VPS - port SSH/akses host tidak menjadi bagian
dari permukaan serang lab ini (hanya port 8095 yang dipublish lewat
`docker-compose.yml`).

## Alur Rantai Eksploitasi

Lihat `docs/VULNERABILITIES.md` untuk payload persis. Ringkas:

1. **Recon** - `nmap -p-` menemukan port 8095; `robots.txt` menemukan `/staff-x7k2/`.
2. **IDOR** (`track.php`) - lihat data pengiriman customer lain via ID sekuensial,
   dapat petunjuk naratif ke sistem internal.
3. **SQLi filter-bypass** (`search.php` / `staff-x7k2/login.php`) - filter blocklist
   non-recursive dilewati dengan teknik nested-keyword, dipakai untuk bypass login
   staff portal.
4. **Command Injection** (`staff-x7k2/courier-check.php`) - `shell_exec()` tanpa
   escaping -> shell sebagai `www-data`.
5. **Privilege Escalation** - sudo NOPASSWD misconfig pada `/usr/bin/less` (GTFOBins)
   -> root shell.

## Struktur Repo

```
docker/           Dockerfile image lab (Apache+PHP+MySQL+sudo misconfig)
docker-compose.yml Entry point deploy (docker compose up -d --build), port 8095
app/www/          Source PHP yang di-deploy ke dalam image (/var/www/nusalog)
app/sql/          Skema + seed data MySQL
docs/             Dokumentasi (arsitektur, kunci jawaban, checklist pengujian)
```

## Kenapa Docker Compose, Bukan VM/Image Terpisah?

Lab ini di-deploy sebagai satu container yang dibangun & dijalankan langsung
di VPS lewat `docker compose up -d --build`. Ini menyederhanakan alur kerja
instruktur seminimal mungkin: tidak perlu VM terpisah, tidak perlu proses
build image (Packer/autoinstall ISO/VirtualBox/OVA), cukup VPS mana pun yang
punya Docker + `git clone` + satu perintah. Detail lengkap ada di `README.md`.

## Keputusan Desain Kunci

- **Apache + mod_php** (bukan Nginx + php-fpm) - lebih sederhana untuk instalasi
  satu-langkah dalam image tanpa perlu konfigurasi socket/pool terpisah.
- **User DB aplikasi tanpa hak `FILE`/`SUPER`** - mencegah jalur privesc tak
  disengaja lewat `SELECT ... INTO OUTFILE` yang bisa memotong rantai eksploitasi
  yang dimaksud (SQLi seharusnya dipakai untuk auth bypass, bukan drop webshell).
- **MySQL tidak dipublish ke host** - hanya diakses lewat `localhost`/Unix
  socket di dalam container yang sama; `docker-compose.yml` cuma mem-publish
  port aplikasi (8095).
- **Tidak ada firewall tambahan (`ufw`) di dalam container** - Docker secara
  default sudah membatasi port masuk ke yang di-publish lewat `ports:` di
  `docker-compose.yml` (hanya 8095), sementara koneksi keluar (dibutuhkan agar
  reverse shell dari command injection bisa dipakai) tetap terbuka.
