# Rencana & Status Pengujian

## Sudah Diverifikasi

Semua item di bawah sudah benar-benar dijalankan dan dikonfirmasi berhasil
selama pengembangan lab ini (bukan sekadar asumsi teoretis):

- [x] `docker build -f docker/Dockerfile .` -> **berhasil**, image jadi.
- [x] `docker compose up -d --build` + `docker compose logs` -> Apache dan
      MySQL sama-sama start tanpa error di dalam container.
- [x] **Aplikasi PHP dijalankan langsung** (`php -S` + MySQL Docker) dan lewat
      container penuh (Apache+PHP+MySQL asli via `service`, bukan systemctl) -
      end-to-end, seluruh rantai eksploitasi dikonfirmasi jalan:
  - [x] IDOR di `track.php?tracking_id=100013` membocorkan `internal_remarks`.
  - [x] Payload SQLi naif (`' OR 1=1 --`, `' OR '1'='1`, `admin'-- `) **gagal**
        dibendung filter (sesuai desain - tidak boleh terlalu mudah).
  - [x] Payload nested-keyword (`SelSELECTect`, `UNIunionON`) **berhasil**
        bypass filter dan dikonfirmasi lewat `search.php` (union data leak) dan
        `staff-x7k2/login.php` (auth bypass, HTTP 302 ke dashboard sebagai admin).
  - [x] Command injection di `courier-check.php` mengeksekusi `id`/`whoami`,
        dan pada harness Apache+PHP-FPM asli terbukti berjalan sebagai
        `uid=33(www-data)` - bukan root, sesuai desain (perlu privesc lanjutan).
  - [x] Privesc `sudo NOPASSWD` pada `/usr/bin/less` diuji terpisah di container
        Ubuntu 22.04 bersih (simulasi pty via `script`) - shell escape `!/bin/sh`
        terbukti menghasilkan `uid=0(root)`.
  - [x] `dashboard.php` (login customer resmi) terbukti ter-scope dengan benar
        (hanya menampilkan shipment milik sendiri, tanpa `internal_remarks`) -
        kontras yang disengaja dengan IDOR di `track.php`.

## Checklist Akhir Manual (setelah `docker compose up -d --build` di VPS)

Wajib dilakukan sebelum lab dianggap siap dipakai peserta:

1. [ ] `docker compose up -d --build` selesai tanpa error, dan
       `docker compose ps` menunjukkan container `nusalog` dalam status `Up`.
2. [ ] `curl http://<ip-vps>:8095/` dari luar VPS mengembalikan halaman
       NusaLog (bukan connection refused/timeout).
3. [ ] `nmap -p- <ip-vps>` dari luar VPS menunjukkan port aplikasi (8095)
       terbuka; hanya port lain di luar 8095 yang boleh muncul adalah port
       yang memang dibuka host VPS itu sendiri (mis. SSH), bukan dari container.
4. [ ] `nmap -p- --top-ports 1000` (scan default) **tidak** menampilkan port
       8095 - konfirmasi bahwa port memang di luar daftar top-1000, memaksa
       full port scan (`-p-`).
5. [ ] Walkthrough manual seluruh rantai di `docs/VULNERABILITIES.md` #1-#4
       terhadap container yang benar-benar hidup di VPS - dari recon sampai
       root shell (di dalam container) + `cat /root/flag.txt`.
6. [ ] `docker compose restart` (atau reboot VPS), pastikan container
       otomatis start lagi (`restart: unless-stopped`) dan aplikasi tetap
       bisa diakses.

## Cara Iterasi Cepat (Tanpa Rebuild Penuh)

```bash
# 1. Jalankan MySQL + PHP langsung (paling cepat, untuk logic PHP/SQLi)
docker run -d --name nusalog-mysql -e MYSQL_ROOT_PASSWORD=rootpw \
  -e MYSQL_DATABASE=nusalog -p 33061:3306 mysql:8.0
docker exec -i nusalog-mysql mysql -uroot -prootpw < app/sql/schema.sql
docker exec -i nusalog-mysql mysql -uroot -prootpw < app/sql/seed.sql
NUSALOG_DB_HOST=127.0.0.1 NUSALOG_DB_PORT=33061 NUSALOG_DB_USER=root \
NUSALOG_DB_PASS=rootpw php -S 127.0.0.1:8091 -t app/www

# 2. Atau image penuh (Apache+PHP+MySQL+sudoers), setara deploy sungguhan
docker compose up -d --build
```

Baru setelah logic PHP dan `docker/Dockerfile` terbukti benar lewat cara di
atas, jalankan `docker compose up -d --build` di VPS sungguhan - ini yang jadi
checkpoint integrasi sebelum lab dipakai peserta (lihat "Checklist Akhir
Manual" di atas).
