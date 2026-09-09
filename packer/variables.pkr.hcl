variable "iso_url" {
  type        = string
  default     = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
  description = <<-EOT
    URL ISO Ubuntu Server 22.04 LTS (x86_64). Ubuntu menghapus ISO point-release
    lama dari mirror utama seiring waktu - verifikasi ulang URL & checksum ini
    di https://releases.ubuntu.com/22.04/ sebelum build jika gagal download.
  EOT
}

variable "iso_checksum" {
  type        = string
  default     = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
  description = "Checksum untuk iso_url di atas (dari SHA256SUMS resmi Ubuntu). Wajib re-verify jika iso_url diubah."
}

variable "vm_name" {
  type    = string
  default = "nusalog-lab"
}

variable "app_port" {
  type        = number
  default     = 8082
  description = "Port non-standar tempat web NusaLog berjalan (bukan 80/443)."
}

variable "disk_size_mb" {
  type    = number
  default = 15360
}

variable "memory_mb" {
  type    = number
  default = 2048
}

variable "cpus" {
  type    = number
  default = 2
}

variable "ssh_username" {
  type        = string
  default     = "packer"
  description = "Akun sementara untuk provisioning - dihapus/tidak relevan setelah image jadi (peserta tidak diberi kredensial ini)."
}

variable "ssh_password" {
  type      = string
  default   = "PackerBuildTemp!2025"
  sensitive = true
}

variable "headless" {
  type    = bool
  default = true
}

variable "output_directory" {
  type    = string
  default = "output/nusalog-lab"
}
