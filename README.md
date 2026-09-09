# Lab Pentest "PT Nusantara Logistik" (OVA)

Lab pentest bergaya **assessment** (bukan CTF flag-based) dalam bentuk OVA yang
bisa diimport ke VirtualBox/VMware. Peserta melakukan recon (nmap) terhadap VM,
menemukan sebuah website perusahaan logistik fiktif di port non-standar, dan
harus menemukan + **melaporkan** rantai kerentanan yang berujung pada root
shell.

Lihat `docs/ARCHITECTURE.md` untuk gambaran teknis dan `docs/VULNERABILITIES.md`
untuk kunci jawaban instruktur (jangan dibagikan ke peserta).

## Build OVA

OVA dibangun di **GitHub Actions** (bukan lokal), karena target harus x86_64
dan mesin pengembang lab ini adalah Mac Apple Silicon tanpa VirtualBox.

1. Push repo ini ke GitHub.
2. Buka tab **Actions** -> workflow **"Build NusaLog Lab OVA"** -> **Run workflow**.
3. Tunggu build selesai (~20-40 menit tergantung runner).
4. Unduh artifact `nusalog-lab-ova` dari halaman run yang sudah selesai.
5. Import file `.ova` ke VirtualBox/VMware, lalu ikuti checklist di
   `docs/TESTING.md` bagian "Checklist Akhir Manual" sebelum dipakai peserta.

**Versi VirtualBox yang disarankan untuk import:** 7.0.x ke atas (menyesuaikan
versi yang dipasang di runner `ubuntu-latest` saat build - dicek otomatis lewat
`VBoxManage --version` di log workflow).

### Risiko/Catatan Build

- **Titik risiko infra terbesar:** ketersediaan VirtualBox + modul kernel
  `vboxdrv` di runner GitHub Actions. Workflow sudah menyertakan fallback
  instalasi via `apt-get`, tapi baru terbukti benar setelah dijalankan sekali.
- **`boot_command` GRUB** (trigger autoinstall Ubuntu) adalah bagian paling
  rawan dari template Packer - kemungkinan perlu penyesuaian keystroke/timing
  setelah dicoba langsung di CI.
- **Checksum ISO** di `packer/variables.pkr.hcl` mengarah ke
  `ubuntu-22.04.5-live-server-amd64.iso`. Jika Ubuntu merilis point-release baru
  dan URL lama tidak lagi tersedia, update `iso_url`/`iso_checksum` sesuai
  https://releases.ubuntu.com/22.04/SHA256SUMS.
- **Ukuran OVA:** perkiraan 1.5-4GB, tercatat di job summary setelah build
  pertama. Jika mendekati/melebihi kuota storage Actions, pertimbangkan publish
  sebagai GitHub Release asset atau storage eksternal (S3/R2) sebagai
  pengganti/tambahan artifact Actions.

## Pengujian Lokal (Tanpa VirtualBox)

Karena mesin pengembang tidak punya VirtualBox, iterasi cepat dilakukan lewat
PHP dev server + Docker MySQL, atau lewat `docker/Dockerfile.dev` (mensimulasikan
Apache+PHP+MySQL+sudoers tanpa Packer/VirtualBox). Lihat `docs/TESTING.md` untuk
perintah lengkap dan daftar apa saja yang sudah/belum terverifikasi.

## Struktur Repo

```
packer/     Template Packer + autoinstall Ubuntu + provisioning scripts
app/        Source PHP + skema/seed database
docker/     Harness pengujian lokal (dev only)
docs/       Arsitektur, kunci jawaban instruktur, rencana pengujian
.github/    Workflow build OVA
```

## Untuk Peserta Lab

Tidak ada informasi apa pun di sini - dokumentasi kerentanan sengaja dipisah ke
`docs/VULNERABILITIES.md` yang tidak ikut ter-deploy ke image dan hanya untuk
instruktur/penilai.
