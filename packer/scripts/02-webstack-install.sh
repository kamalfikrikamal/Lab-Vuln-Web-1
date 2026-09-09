#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get install -y apache2 php php-mysql php-mbstring libapache2-mod-php mysql-server

systemctl enable apache2
systemctl enable mysql
systemctl start mysql
systemctl start apache2
