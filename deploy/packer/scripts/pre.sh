#!/bin/bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



set -ex



# Partitioning and Filesystem
#---------------------------------------
sgdisk --clear ${disk}
sgdisk --new 1:0:+1M --change-name 1:'Boot' --typecode 1:ef02 ${disk}
sgdisk --new 2:0:0 --change-name 2:'Root' ${disk}

mkfs.ext4 ${disk}p2

mkdir ${mountPoint}
mount ${disk}p2 ${mountPoint}



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