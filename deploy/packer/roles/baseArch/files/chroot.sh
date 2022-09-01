#!/usr/bin/bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



set -ex



# Standard Configuration
#---------------------------------------
# Time zone.
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Localization.
sed -Ei 's/^#(en_US\.UTF-8 UTF-8)/\1/g' /etc/locale.gen # Uncomment #en_US.UTF-8 UTF-8.
sed -Ei 's/^#(pt_BR\.UTF-8 UTF-8)/\1/g' /etc/locale.gen # Uncomment #pt_BR.UTF-8 UTF-8.
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

#-------------------------------------------------------------------------------
cat > /etc/systemd/network/main.network << 'EOF'
[Match]
Name = en*

[Network]
DHCP = yes

[DHCPv4]
UseDomains = yes
EOF
#-------------------------------------------------------------------------------
systemctl enable systemd-{networkd,resolved,timesyncd}

# Bootloader.
grub-install ${disk}
kernelParameters='nomodeset console=ttyS0,9600n8 earlyprintk=serial,ttyS0,9600 loglevel=6'
sed -Ei "s/^(GRUB_CMDLINE_LINUX_DEFAULT)=.*/\1=\"${kernelParameters}\"/g" /etc/default/grub # Set GRUB_CMDLINE_LINUX_DEFAULT.
sed -Ei 's/^(GRUB_TIMEOUT)=.*/\1=0/g' /etc/default/grub # Set GRUB_TIMEOUT=0.
grub-mkconfig -o /boot/grub/grub.cfg


# Sudo.
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel


# Services.
systemctl enable sshd