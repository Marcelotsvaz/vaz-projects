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

useradd -rms /usr/bin/nologin ${user}
cd /home/${user}/
sudo -u ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1
aws s3 sync s3://${bucket}/deployment/ deployment/ --no-progress
chmod 600 deployment/secrets.env deployment/tls/*
EOF

cd loadBalancer/
docker compose up --detach --quiet-pull

systemctl enable /home/${user}/loadBalancer/systemdUnits/*



# Start Services
#---------------------------------------
systemctl start dehydrated.timer



echo 'Finished Instance Configuration Script.'