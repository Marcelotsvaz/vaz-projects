#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



echo 'Starting Instance Configuration Script...'



# Script Setup
#---------------------------------------
set -e	# Abort on error.



# System Setup
#---------------------------------------
echo ${sshKey} > ~marcelotsvaz/.ssh/authorized_keys	# Admin user.
hostnamectl set-hostname ${domainName}



# Monitoring data volume setup
#---------------------------------------
aws ec2 wait volume-in-use --volume-ids ${dataVolumeId}
dataDisk=$(lsblk -nro SERIAL,PATH | grep ${dataVolumeId/-/} | cut -d ' ' -f2)
dataPartition=$(lsblk -nro PKNAME,FSTYPE,PATH | grep "^${dataDisk/\/dev\//} " | grep ext4 | cut -d ' ' -f3)

# Format volume if there's no partitions.
if [[ -z ${dataPartition} ]]; then
	echo Formatting new volume...
	
	sgdisk --clear ${dataDisk}
	sgdisk --new 1:0:0 --change-name 1:'Data' ${dataDisk}
	
	dataPartition=$(lsblk -nro PKNAME,PATH | grep "^${dataDisk/\/dev\//} " | cut -d ' ' -f2)
	
	mkfs.ext4 ${dataPartition}
fi

mkdir -p /var/lib/docker/volumes
mount ${dataPartition} /var/lib/docker/volumes



# Monitoring stack start
#---------------------------------------
useradd -rms /usr/bin/nologin -G docker ${user}
cd /home/${user}
sudo -Eu ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1
aws s3 cp s3://${bucket}/deployment/secrets.env deployment/ --no-progress
EOF

cd monitoring
systemctl enable --now docker
docker compose --env-file ../deployment/secrets.env up --detach --quiet-pull


echo 'Finished Instance Configuration Script.'