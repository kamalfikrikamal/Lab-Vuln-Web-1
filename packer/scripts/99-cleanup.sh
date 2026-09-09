#!/bin/bash
set -euxo pipefail

apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/* /var/tmp/*

# Bersihkan jejak build agar setiap boot pertama dari OVA hasil clone terasa unik.
truncate -s 0 /etc/machine-id || true
rm -f /var/lib/dbus/machine-id || true
ln -sf /etc/machine-id /var/lib/dbus/machine-id || true
rm -f /etc/ssh/ssh_host_* || true

find /var/log -type f -exec truncate -s 0 {} \;
rm -f /root/.bash_history
rm -f /home/*/.bash_history
history -c || true
cloud-init clean --logs || true
