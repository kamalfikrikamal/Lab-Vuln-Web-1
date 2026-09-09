# Arsitektur Lab NusaLog

## Gambaran Umum

Satu VM Ubuntu Server 22.04 LTS (x86_64), didistribusikan sebagai OVA, berisi
website perusahaan logistik fiktif "PT Nusantara Logistik" dengan kerentanan
yang disengaja untuk latihan pentest (bukan CTF flag-based - peserta melaporkan
temuan, bukan mengejar flag).

```
Peserta (VirtualBox/VMware, laptop mana pun)
        |
        | nmap -p-
        v
+-----------------------------------+
|  Ubuntu Server 22.04 (VM)          |
|                                     |
|  22/tcp  -> SSH                    |
|  8082/tcp -> Apache (NusaLog web)  |  <- port non-standar, di luar top-1000 nmap
|                                     |
|  MySQL: 127.0.0.1 only (tidak      |
|  pernah diekspos ke jaringan)      |
+-----------------------------------+
```

## Alur Rantai Eksploitasi

Lihat `docs/VULNERABILITIES.md` untuk payload persis. Ringkas:

1. **Recon** - `nmap -p-` menemukan port 8082; `robots.txt` menemukan `/staff-x7k2/`.
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
packer/          Template Packer (virtualbox-iso) + autoinstall Ubuntu + provisioning scripts
app/www/          Source PHP yang di-deploy ke VM (/var/www/nusalog)
app/sql/          Skema + seed data MySQL
docker/           Harness pengujian lokal (dev only, tidak ikut ke OVA)
.github/workflows/ Workflow build OVA via GitHub Actions
docs/             Dokumentasi (arsitektur, kunci jawaban, checklist pengujian)
```

## Kenapa Build di GitHub Actions, Bukan Lokal?

OVA target harus x86_64 (agar diimport peserta berlaptop Intel/AMD dengan
VirtualBox biasa). Mesin pengembang untuk lab ini adalah Mac Apple Silicon
(arm64) tanpa akselerasi hardware native untuk guest x86_64, sehingga build
dilakukan di runner GitHub Actions (x86_64) yang menjalankan Packer dengan
builder `virtualbox-iso`, lalu OVA hasil build diunduh sebagai artifact. Detail
lengkap ada di `README.md`.

## Keputusan Desain Kunci

- **Apache + mod_php** (bukan Nginx + php-fpm) - lebih sederhana untuk instalasi
  unattended satu-langkah tanpa perlu konfigurasi socket/pool terpisah.
- **User DB aplikasi tanpa hak `FILE`/`SUPER`** - mencegah jalur privesc tak
  disengaja lewat `SELECT ... INTO OUTFILE` yang bisa memotong rantai eksploitasi
  yang dimaksud (SQLi seharusnya dipakai untuk auth bypass, bukan drop webshell).
- **MySQL hanya bind ke `127.0.0.1`** - tidak pernah jadi target langsung dari
  jaringan; koneksi PHP memakai `localhost` (Unix socket).
- **`ufw` outbound tetap terbuka** - diperlukan agar reverse shell dari command
  injection benar-benar bisa dipakai.
