#!/usr/bin/bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



set -ex



# Install Arch Linux
#---------------------------------------
pacstrap -c ${mountPoint} --noprogressbar \
base linux grub \
openssh sudo aws-cli gdisk \
nano \
docker docker-compose prometheus-node-exporter promtail \
dehydrated

# DNS.
ln -sf /run/systemd/resolve/resolv.conf ${mountPoint}/etc/resolv.conf

# Fstab.
genfstab -U ${mountPoint} >> ${mountPoint}/etc/fstab