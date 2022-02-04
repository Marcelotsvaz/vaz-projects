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
hostnamectl set-hostname ${domainName}

echo ${sshKey} > ~marcelotsvaz/.ssh/authorized_keys

useradd -rms /usr/bin/nologin -G docker ${user}

cd /home/${user}/

sudo -Eu ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1

aws s3 sync s3://${bucket}/deployment/ deployment/ --no-progress
mkdir deployment/logs/

docker-compose up --detach
docker-compose exec application ./manage.py migrate --no-input
EOF

systemctl enable /home/${user}/server/systemdUnits/*



# Start Services
#---------------------------------------
systemctl start backup.timer dehydrated.timer nginx



echo 'Finished Instance Configuration Script.'