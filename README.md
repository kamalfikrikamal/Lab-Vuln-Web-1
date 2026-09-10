# Lab Pentest "PT Nusantara Logistik"

Lab pentest bergaya **assessment** (bukan CTF flag-based), di-deploy lewat
Docker Compose ke VPS mana pun. Peserta melakukan recon (nmap) terhadap host,
menemukan sebuah website perusahaan logistik fiktif di port non-standar, dan
harus menemukan + **melaporkan** rantai kerentanan yang berujung pada root
shell (di dalam container).

Lihat `docs/ARCHITECTURE.md` untuk gambaran teknis dan `docs/VULNERABILITIES.md`
untuk kunci jawaban instruktur (jangan dibagikan ke peserta).

## Install di VPS

Butuh VPS mana pun yang sudah punya Docker + Docker Compose plugin.

1. Clone/copy repo ini ke VPS (mis. `git clone` atau `rsync`).
2. Dari root repo di VPS, jalankan:
   ```bash
   docker compose up -d --build
   ```
3. Aplikasi langsung jalan di `http://<ip-vps>:8095` - satu container berisi
   Apache+PHP+MySQL+aturan sudo yang jadi jalur privesc di lab ini (lihat
   `docker/Dockerfile`).
4. Ikuti checklist di `docs/TESTING.md` bagian "Checklist Akhir Manual"
   sebelum dipakai peserta.

**Catatan:** setiap `docker compose up -d --build` ulang akan membangun ulang
image dan me-reset state (database ter-seed ulang dari `app/sql`) - berguna
untuk mengembalikan lab ke kondisi awal di antara sesi peserta.

## Struktur Repo

```
docker/     Dockerfile image lab (Apache+PHP+MySQL+sudo misconfig)
app/        Source PHP + skema/seed database
docs/       Arsitektur, kunci jawaban instruktur, rencana pengujian
```

## Untuk Peserta Lab

Tidak ada informasi apa pun di sini - dokumentasi kerentanan sengaja dipisah ke
`docs/VULNERABILITIES.md` yang tidak ikut ter-deploy ke image dan hanya untuk
instruktur/penilai.
