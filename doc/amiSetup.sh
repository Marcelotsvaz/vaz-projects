#!/bin/bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Dependencies
#---------------------------------------
pacman -Syu --noconfirm arch-install-scripts reflector
reflector --protocol https --latest 50 --sort rate --save /etc/pacman.d/mirrorlist



# Variables
#---------------------------------------
export AWS_DEFAULT_OUTPUT=text
instanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
availabilityZone=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
mountPoint=/mnt/new



# Create Volume
#---------------------------------------
volumeId=$(aws ec2 create-volume --size 2 --availability-zone ${availabilityZone} --volume-type gp3 --no-encrypted --query 'VolumeId')
aws ec2 wait volume-available --volume-ids ${volumeId}
aws ec2 attach-volume --volume-id ${volumeId} --instance-id ${instanceId} --device /dev/sdf

# Wait for volume to be mounted.
while [[ -z ${disk} ]]; do
	export disk=$(lsblk -nro SERIAL,PATH | grep ${volumeId/-/} | cut -d ' ' -f2)    # Get attached EBS volume device path.
	sleep 1
done



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
docker docker-compose prometheus-node-exporter promtail \
dehydrated

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
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
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


# Docker
#-------------------------------------------------------------------------------
mkdir /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
    "dns-opts": [ "ndots:1" ]
}
EOF
#-------------------------------------------------------------------------------
# Docker adds ndots:0 to container's /etc/resolv.conf, which disables search domains in musl.
# 
# If we specify any DNS option Docker stops handling DNS servers listening on 127.0.0.0/8 like systemd-resolved
# stub resolver so we use /run/systemd/resolve/resolv.conf instead of stub-resolv.conf.


# Init scripts.
mkdir -p /usr/local/lib/systemd/system

#-------------------------------------------------------------------------------
cat > /usr/local/lib/instanceScriptsSetup.sh << 'EOF'
#!/bin/bash
# Grow root partition.
disk="/dev/$(lsblk -nro MOUNTPOINT,PKNAME | grep '^/ ' | cut -d ' ' -f2)"
partition="/dev/$(lsblk -nro MOUNTPOINT,KNAME | grep '^/ ' | cut -d ' ' -f2)"

sgdisk --move-second-header ${disk}
sgdisk --delete 2 ${disk}
sgdisk --new 2:0:0 --change-name 2:'Root' ${disk}

partx -u ${disk}

resize2fs ${partition}


# Download user data.
mkdir /tmp/deploy && cd ${_}
curl -s http://169.254.169.254/latest/user-data | tar -xz
mv per*.sh /usr/local/lib/
mv environment.env /etc/environment
EOF
#-------------------------------------------------------------------------------
chmod +x /usr/local/lib/instanceScriptsSetup.sh

#-------------------------------------------------------------------------------
cat > /usr/local/lib/systemd/system/instanceScriptsSetup.service << 'EOF'
[Unit]
Description = Setup Instance Scripts
Requires = network-online.target
After = network-online.target
ConditionFirstBoot = yes

[Service]
Type = oneshot

ExecStart = /usr/local/lib/instanceScriptsSetup.sh

[Install]
WantedBy = multi-user.target
EOF
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
cat > /usr/local/lib/systemd/system/perInstance.service << 'EOF'
[Unit]
Description = Instance Configuration Script
Requires = instanceScriptsSetup.service network-online.target
After = instanceScriptsSetup.service network-online.target
ConditionFirstBoot = yes

[Service]
Type = oneshot

EnvironmentFile = -/etc/environment
ExecStart = /usr/local/lib/perInstance.sh

[Install]
WantedBy = multi-user.target
EOF
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
cat > /usr/local/lib/systemd/system/perBoot.service << 'EOF'
[Unit]
Description = Boot Script
Requires = perInstance.service network-online.target
After = perInstance.service network-online.target
ConditionFileIsExecutable = /usr/local/lib/perBoot.sh

[Service]
Type = oneshot

EnvironmentFile = -/etc/environment
ExecStart = /usr/local/lib/perBoot.sh

[Install]
WantedBy = multi-user.target
EOF
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
cat > /usr/local/lib/systemd/system/perShutdown.service << 'EOF'
[Unit]
Description = Shutdown Script
Requires = perInstance.service network-online.target
After = perInstance.service network-online.target
ConditionFileIsExecutable = /usr/local/lib/perShutdown.sh

[Service]
Type = oneshot
RemainAfterExit = true

EnvironmentFile = -/etc/environment
ExecStop = /usr/local/lib/perShutdown.sh

[Install]
WantedBy = multi-user.target
EOF
#-------------------------------------------------------------------------------

systemctl disable systemd-firstboot
systemctl enable instanceScriptsSetup per{Instance,Boot,Shutdown}


# Promtail
#-------------------------------------------------------------------------------
cat > /etc/loki/promtail.yaml << 'EOF'
server:
    http_listen_port: 9080
    grpc_listen_port: 0


clients:
  - url: http://monitoring:3100/loki/api/v1/push


positions:
    filename: /var/lib/promtail/positions.yaml


scrape_configs:
  - job_name: journal
    journal:
        path: /var/log/journal
        json: true
        labels:
            job: systemd-journal
            hostname: ${hostname}
    
  - job_name: nginx
    static_configs:
      - labels:
            job: nginx
            __path__: /var/log/nginx/*.log
EOF
#-------------------------------------------------------------------------------

mkdir /usr/local/lib/systemd/system/promtail.service.d
#-------------------------------------------------------------------------------
cat > ${_}/override.conf << 'EOF'
[Service]
EnvironmentFile = -/etc/environment
ExecStart =
ExecStart = /usr/bin/promtail -config.file /etc/loki/promtail.yaml -config.expand-env true
EOF
#-------------------------------------------------------------------------------



# Services.
systemctl enable sshd docker prometheus-node-exporter promtail



# Clean up.
exit
rm ${mountPoint}/{root/.bash_history,var/log/pacman.log}
rm ${mountPoint}/etc/machine-id



# Create AMI
#---------------------------------------
umount -R ${mountPoint}
rm -r ${mountPoint}
aws ec2 detach-volume --volume-id ${volumeId}

# Create AMI snapshot.
snapshotId=$(aws ec2 create-snapshot \
    --volume-id ${volumeId} \
    --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=Arch Linux AMI Snapshot}]' \
    --query 'SnapshotId')

# Clean up.
imageId=$(aws ec2 describe-images --filters 'Name=name,Values=Arch Linux AMI' --query 'Images[0].ImageId')
aws ec2 deregister-image --image-id ${imageId}
aws ec2 wait volume-available --volume-ids ${volumeId}
aws ec2 delete-volume --volume-id ${volumeId}

# Register AMI.
aws ec2 wait snapshot-completed --snapshot-ids ${snapshotId}
newImageId=$(aws ec2 register-image \
    --name 'Arch Linux AMI' \
    --architecture x86_64 \
    --virtualization-type hvm \
    --ena-support \
    --root-device-name /dev/xvda \
    --block-device-mappings '[{"DeviceName": "/dev/xvda","Ebs":{"SnapshotId":"'${snapshotId}'","VolumeType":"gp3"}}]' \
    --query 'ImageId'
)
