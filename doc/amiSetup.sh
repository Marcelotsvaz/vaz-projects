#!/bin/bash



# Dependencies
#---------------------------------------
pacman -Syu --noconfirm arch-install-scripts reflector
reflector --protocol https --latest 50 --sort rate --save /etc/pacman.d/mirrorlist


# Variables
#---------------------------------------
export AWS_DEFAULT_OUTPUT=text
instanceID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
availabilityZone=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
mountPoint=/mnt/new


# Create Volume
#---------------------------------------
volumeID=$(aws ec2 create-volume --size 2 --availability-zone ${availabilityZone} --volume-type gp3 --no-encrypted --query 'VolumeId')
aws ec2 wait volume-available --volume-ids ${volumeID}
aws ec2 attach-volume --volume-id ${volumeID} --instance-id ${instanceID} --device /dev/sdf
aws ec2 wait volume-in-use --volume-ids ${volumeID}
sleep 3
export disk=$(lsblk -nro SERIAL,PATH | grep ${volumeID/-/} | cut -d ' ' -f2) # Get attached EBS volume device path.


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
pacstrap -c ${mountPoint} \
base linux grub \
openssh sudo aws-cli gdisk \
nano \
docker docker-compose nginx

# Fstab.
genfstab -U ${mountPoint} >> ${mountPoint}/etc/fstab


# Chroot
#---------------------------------------
mount --bind /dev ${mountPoint}/dev
mount --bind /sys ${mountPoint}/sys
mount --bind /proc ${mountPoint}/proc
chroot ${mountPoint}


# Standard Configuration
#---------------------------------------
# Time zone.
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

# Localization.
sed -Ei 's/^#(en_US\.UTF-8 UTF-8)/\1/g' /etc/locale.gen # Uncomment #en_US.UTF-8 UTF-8.
sed -Ei 's/^#(pt_BR\.UTF-8 UTF-8)/\1/g' /etc/locale.gen # Uncomment #pt_BR.UTF-8 UTF-8.
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Network.
echo 'arch-ec2' > /etc/hostname

#-------------------------------------------------------------------------------
cat > /etc/systemd/network/main.network << 'EOF'
[Match]
Name = en*

[Network]
DHCP = yes
EOF
#-------------------------------------------------------------------------------
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
systemctl enable systemd-{networkd,resolved,timesyncd}

# Bootloader.
grub-install ${disk}
kernelParameters='nomodeset console=ttyS0,9600n8 earlyprintk=serial,ttyS0,9600 loglevel=6'
sed -Ei "s/^(GRUB_CMDLINE_LINUX_DEFAULT)=.*/\1=\"${kernelParameters}\"/g" /etc/default/grub # Set GRUB_CMDLINE_LINUX_DEFAULT.
sed -Ei 's/^(GRUB_TIMEOUT)=.*/\1=0/g' /etc/default/grub # Set GRUB_TIMEOUT=0.
grub-mkconfig -o /boot/grub/grub.cfg


# Custom Configuration
#---------------------------------------
# Users.
mkdir -m 700 /etc/skel/.ssh
touch /etc/skel/.ssh/authorized_keys
rm /etc/skel/.bash*

useradd -mG wheel marcelotsvaz


# Sudo.
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel


# SSH
#-------------------------------------------------------------------------------
cat >> /etc/ssh/sshd_config << 'EOF'

# Custom configuration.
PasswordAuthentication no

PubkeyAcceptedKeyTypes ssh-ed25519

KexAlgorithms curve25519-sha256
HostKeyAlgorithms ssh-ed25519
Ciphers chacha20-poly1305@openssh.com
MACs hmac-sha2-512-etm@openssh.com
EOF
#-------------------------------------------------------------------------------


# Bash
#-------------------------------------------------------------------------------
cat >> /etc/bash.bashrc << 'EOF'

# Custom configuration.
export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
export AWS_DEFAULT_OUTPUT=table

green='\[\e[0;32m\]'
blue='\[\e[1;34m\]'
reset='\[\e[m\]'
PS1="┌[\A][${green}\u@\h ${blue}\w${reset}]\$\n└> "

alias grep='grep --color=auto'
alias ls='ls --color=auto'
EOF
#-------------------------------------------------------------------------------


# OpenSSL
sed -Ei 's/^\[ new_oids \]$/\.include custom\.cnf\n\0/g' /etc/ssl/openssl.cnf # Add ".include custom.cnf".
#-------------------------------------------------------------------------------
cat > /etc/ssl/custom.cnf << 'EOF'
# Custom configuration.
openssl_conf = default_conf

[default_conf]
ssl_conf = ssl_sect

[ssl_sect]
system_default = system_default_sect

[system_default_sect]
MinProtocol = TLSv1.2
CipherSuites = TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384
CipherString = ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES256-GCM-SHA384;
Curves = X25519:secp521r1
EOF
#-------------------------------------------------------------------------------


# Init scripts.
mkdir /root/init

#-------------------------------------------------------------------------------
cat > /root/init/instanceScriptsSetup.sh << 'EOF'
#!/bin/bash
# Grow root partition.
disk="/dev/disk/by-uuid/$(lsblk -nro MOUNTPOINT,UUID | grep '^/ ' | cut -d ' ' -f2)"
partition="/dev/disk/by-partuuid/$(lsblk -nro MOUNTPOINT,PARTUUID | grep '^/ ' | cut -d ' ' -f2)"

sgdisk --move-second-header ${disk}
sgdisk --delete 2 ${disk}
sgdisk --new 2:0:0 --change-name 2:'Root' ${disk}

partx -u ${disk}

resize2fs ${partition}


# Download user data.
curl -s http://169.254.169.254/latest/user-data | tar -xz -C /root/init/
EOF
#-------------------------------------------------------------------------------
chmod +x /root/init/instanceScriptsSetup.sh

#-------------------------------------------------------------------------------
cat > /etc/systemd/system/instanceScriptsSetup.service << 'EOF'
[Unit]
Description = Setup Instance Scripts
Requires = network-online.target
After = network-online.target
ConditionPathExists = !/root/init/instanceScriptsSetup.done

[Service]
Type = oneshot

ExecStart = /root/init/instanceScriptsSetup.sh
ExecStart = touch /root/init/instanceScriptsSetup.done

[Install]
WantedBy = multi-user.target
EOF
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
cat > /etc/systemd/system/perInstance.service << 'EOF'
[Unit]
Description = Instance Configuration Script
Requires = instanceScriptsSetup.service network-online.target
After = instanceScriptsSetup.service network-online.target
ConditionPathExists = !/root/init/perInstance.done

[Service]
Type = oneshot

EnvironmentFile = -/root/init/environment.sh
ExecStart = /root/init/perInstance.sh
ExecStart = touch /root/init/perInstance.done

[Install]
WantedBy = multi-user.target
EOF
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
cat > /etc/systemd/system/perBoot.service << 'EOF'
[Unit]
Description = Boot Script
Requires = perInstance.service network-online.target
After = perInstance.service network-online.target
ConditionFileIsExecutable = /root/init/perBoot.sh

[Service]
Type = oneshot

EnvironmentFile = -/root/init/environment.sh
ExecStart = /root/init/perBoot.sh

[Install]
WantedBy = multi-user.target
EOF
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
cat > /etc/systemd/system/perShutdown.service << 'EOF'
[Unit]
Description = Shutdown Script
Requires = perInstance.service network-online.target
After = perInstance.service network-online.target
ConditionFileIsExecutable = /root/init/perShutdown.sh

[Service]
Type = oneshot
RemainAfterExit = true

EnvironmentFile = -/root/init/environment.sh
ExecStop = /root/init/perShutdown.sh

[Install]
WantedBy = multi-user.target
EOF
#-------------------------------------------------------------------------------

systemctl enable instanceScriptsSetup perInstance perBoot perShutdown sshd docker


# Clean up.
exit
rm ${mountPoint}/{root/.bash_history,var/log/pacman.log}


# Create AMI
#---------------------------------------
umount -R ${mountPoint}
rm -r ${mountPoint}
aws ec2 detach-volume --volume-id ${volumeID}
aws ec2 wait volume-available --volume-ids ${volumeID}

snapshotID=$(aws ec2 create-snapshot \
    --volume-id ${volumeID} \
    --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=Arch Linux AMI Snapshot}]' \
    --query 'SnapshotId')
aws ec2 wait snapshot-completed --snapshot-ids ${snapshotID}
aws ec2 delete-volume --volume-id ${volumeID}

imageId=$(aws ec2 describe-images --filters 'Name=name,Values=Arch Linux AMI' --query 'Images[0].ImageId')
aws ec2 deregister-image --image-id ${imageId}
newImageId=$(aws ec2 register-image \
    --name 'Arch Linux AMI' \
    --architecture x86_64 \
    --virtualization-type hvm \
    --ena-support \
    --root-device-name /dev/xvda \
    --block-device-mappings '[{"DeviceName": "/dev/xvda","Ebs":{"SnapshotId":"'${snapshotID}'","VolumeType":"gp3"}}]' \
    --query 'ImageId'
)

# Share with UTL and Venditore account.
aws ec2 modify-image-attribute \
    --image-id ${newImageId} \
    --launch-permission "Add=[ { UserId = 883778058666 }, { UserId = 756912632867 } ]"
