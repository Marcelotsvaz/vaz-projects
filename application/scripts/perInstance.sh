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

useradd -rms /usr/bin/nologin ${user}
cd /home/${user}/
sudo -Eu ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1
aws s3 cp s3://${bucket}/deployment/secrets.env deployment/ --no-progress
EOF

cd application
systemctl enable --now docker
docker compose --env-file ../deployment/secrets.env up --detach --quiet-pull



echo 'Finished Instance Configuration Script.'