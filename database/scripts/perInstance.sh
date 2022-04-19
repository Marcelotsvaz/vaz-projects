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
hostnamectl set-hostname ${hostname}



# PostgreSQL data volume setup
#---------------------------------------
dataDisk="/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_${dataVolumeId/-/}"
dataPartition="${dataDisk}-part1"

# Wait for volume to be mounted.
while [[ ! -b ${dataDisk} ]]; do
	sleep 1
done

# Make sure partitions are loaded.
partx -u ${dataDisk}

# Format volume if there's no partitions.
if [[ ! -b ${dataPartition} ]]; then
	echo Formatting new volume...
	
	sgdisk --clear ${dataDisk}
	sgdisk --new 1:0:0 --change-name 1:'Docker Volumes' ${dataDisk}
	
	# Wait for partition to be available.
	while [[ ! -b ${dataPartition} ]]; do
		sleep 1
	done
	
	mkfs.ext4 ${dataPartition}
fi

echo "${dataPartition}	/var/lib/docker/volumes	ext4	X-mount.mkdir	0	2" >> /etc/fstab
mount ${dataPartition}



# PostgreSQL start
#---------------------------------------
useradd -rms /usr/bin/nologin ${user}
cd /home/${user}
sudo -Eu ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1
aws s3 cp s3://${bucket}/deployment/secrets.env deployment/ --no-progress
EOF

cd database
systemctl enable --now docker
docker compose --env-file ../deployment/secrets.env up --detach --quiet-pull


echo 'Finished Instance Configuration Script.'