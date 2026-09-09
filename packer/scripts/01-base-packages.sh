#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y -o Dpkg::Options::="--force-confold" upgrade
apt-get install -y curl unzip ufw ca-certificates gnupg lsb-release
