source "virtualbox-iso" "ubuntu2204" {
  guest_os_type = "Ubuntu_64"

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  http_directory = "packer/http"

  # Trigger autoinstall dengan mengedit entri menu GRUB yang sudah ada
  # (tekan "e", turun ke baris "linux", tambahkan parameter autoinstall di
  # akhir baris, lalu F10 untuk boot). Ini menghindari harus menyusun ulang
  # baris linux/initrd/boot dari nol secara manual (pendekatan mode konsol
  # "c" yang lebih rawan salah/timeout). Referensi: dicocokkan dengan
  # boot_command yang terbukti bekerja untuk ISO ubuntu-22.04.5-live-server
  # yang sama persis (rlaun/packer-ubuntu-22.04, builder qemu - mekanisme
  # keystroke GRUB sama untuk builder VM apa pun).
  # boot_wait dinaikkan jadi 15s (dari 5s) - dugaan kuat penyebab dua build
  # sebelumnya gagal ("Timeout waiting for SSH" setelah 60 menit penuh) adalah
  # keystroke "e" terkirim SEBELUM menu GRUB benar-benar tampil di layar VM,
  # sehingga terlewat begitu saja dan VM malah boot ke installer interaktif
  # biasa (yang tidak pernah menyalakan SSH dengan kredensial packer).
  boot_wait = "15s"
  boot_command = [
    "e<wait5s>",
    "<down><down><down>",
    "<end><bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ---<wait>",
    "<f10><wait>"
  ]

  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = "60m"
  ssh_handshake_attempts = 420

  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
  shutdown_timeout = "15m"

  vm_name              = var.vm_name
  guest_additions_mode = "disable"

  disk_size = var.disk_size_mb
  memory    = var.memory_mb
  cpus      = var.cpus
  headless  = var.headless

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--audio", "none"],
    ["modifyvm", "{{.Name}}", "--usb", "off"],
    ["modifyvm", "{{.Name}}", "--nictype1", "82540EM"],
    ["modifyvm", "{{.Name}}", "--chipset", "ich9"],
  ]

  format           = "ova"
  output_directory = var.output_directory
}

build {
  sources = ["source.virtualbox-iso.ubuntu2204"]

  provisioner "file" {
    source      = "app/www"
    destination = "/tmp/app-src"
  }

  provisioner "file" {
    source      = "app/sql"
    destination = "/tmp/sql"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} bash '{{ .Path }}'"
    environment_vars = [
      "APP_PORT=${var.app_port}",
    ]
    scripts = [
      "packer/scripts/01-base-packages.sh",
      "packer/scripts/02-webstack-install.sh",
      "packer/scripts/03-deploy-app.sh",
      "packer/scripts/04-configure-mysql.sh",
      "packer/scripts/05-configure-firewall.sh",
      "packer/scripts/06-configure-sudo-misconfig.sh",
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} bash '{{ .Path }}'"
    scripts = [
      "packer/scripts/99-cleanup.sh",
    ]
  }
}
