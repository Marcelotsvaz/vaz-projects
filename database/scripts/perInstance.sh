#!/usr/bin/env bash
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
partitionName='Docker Volumes'

# Wait for volume to be available.
while [[ ! -b ${dataDisk} ]]; do
	sleep 0.1
done

# Format volume if partition doesn't exist.
if [[ $(partx --show --nr 1 --output name --noheadings ${dataDisk}) != ${partitionName} ]]; then
	echo Formatting new volume...
	
	sgdisk --clear ${dataDisk}
	sgdisk --new 1:0:0 --change-name 1:"${partitionName}" ${dataDisk}
	
	# Wait for partition to be available.
	while [[ ! -b ${dataPartition} ]]; do
		sleep 0.1
	done
	
	mkfs.ext4 ${dataPartition}
fi

# Wait for partition to be available.
while [[ ! -b ${dataPartition} ]]; do
	sleep 0.1
done

echo "${dataPartition}	/var/lib/docker/volumes	ext4	X-mount.mkdir	0	2" >> /etc/fstab
mount ${dataPartition}



# PostgreSQL start
#---------------------------------------
useradd -rms /usr/bin/nologin ${user}
cd /home/${user}/
sudo -u ${user} bash <<- EOF
	curl -s ${repositorySnapshot} | tar -xz --strip-components 1
	aws s3 cp s3://${bucket}/deployment/secrets.env deployment/ --no-progress
	chmod -R go= deployment/secrets.env
EOF

cd database/
docker compose --env-file ../deployment/secrets.env up --detach --quiet-pull



echo 'Finished Instance Configuration Script.'