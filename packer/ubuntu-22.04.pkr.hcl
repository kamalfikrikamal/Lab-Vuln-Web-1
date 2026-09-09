source "virtualbox-iso" "ubuntu2204" {
  guest_os_type = "Ubuntu_64"

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  http_directory = "packer/http"

  # Trigger autoinstall lewat konsol perintah GRUB (tekan "c" di menu GRUB
  # untuk masuk mode command-line, lalu boot kernel/initrd secara manual
  # dengan parameter autoinstall). Ini bagian paling rawan dari seluruh
  # template - timing/keystroke sangat tergantung build ISO, kemungkinan
  # perlu diiterasi ulang setelah dicoba langsung di CI.
  boot_wait = "5s"
  boot_command = [
    "c<wait3s>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ ",
    "<enter><wait3s>",
    "initrd /casper/initrd<enter><wait3s>",
    "boot<enter>"
  ]

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "40m"

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
