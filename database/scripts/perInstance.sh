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

useradd -rms /usr/bin/nologin --uid 70 -G docker ${user}
cd /home/${user}/



# PostgreSQL data volume setup
#---------------------------------------
databaseDataDir="/home/${user}/postgresql"

aws ec2 wait volume-in-use --volume-ids ${dataVolumeId}
dataDisk=$(lsblk -nro SERIAL,PATH | grep ${dataVolumeId/-/} | cut -d ' ' -f2)
dataPartition=$(lsblk -nro PKNAME,FSTYPE,PATH | grep "^${dataDisk/\/dev\//} " | grep ext4 | cut -d ' ' -f3)

# Format volume if there's no partitions.
if [[ -z ${dataPartition} ]]; then
	echo Formatting new volume...
	
	sgdisk --clear ${dataDisk}
	sgdisk --new 1:0:0 --change-name 1:'Data' ${dataDisk}
	
	dataPartition=$(lsblk -nro PKNAME,PATH | grep "^${dataDisk/\/dev\//} " | cut -d ' ' -f2)
	
	uid=$(id -u ${user})
	mkfs.ext4 -E root_owner=${uid}:${uid} ${dataPartition}
fi

mkdir ${databaseDataDir}
mount ${dataPartition} ${databaseDataDir}



# PostgreSQL start
#---------------------------------------
sudo -Eu ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1
aws s3 cp s3://${bucket}/deployment/secrets.env deployment/ --no-progress
EOF

systemctl enable --now docker
docker run --env-file deployment/secrets.env --volume ${databaseDataDir}/data:/var/lib/postgresql/data --network=host --detach postgres:14.1-alpine3.15


echo 'Finished Instance Configuration Script.'