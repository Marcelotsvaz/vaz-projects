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

useradd -rms /usr/bin/nologin -G docker ${user}
cd /home/${user}/
sudo -Eu ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1

aws s3 cp s3://${bucket}/deployment/secrets.sh deployment/secrets.sh --no-progress

docker run --env-file deployment/secrets.sh --detach postgres:14.1-alpine3.15
EOF



echo 'Finished Instance Configuration Script.'