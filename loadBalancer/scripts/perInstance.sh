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
cd /home/${user}
sudo -Eu ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1
aws s3 sync s3://${bucket}/deployment/ deployment/ --no-progress
EOF

cd loadBalancer
systemctl enable --now docker
docker compose up --detach --quiet-pull

systemctl enable /home/${user}/loadBalancer/systemdUnits/*



# Start Services
#---------------------------------------
systemctl start dehydrated.timer



echo 'Finished Instance Configuration Script.'