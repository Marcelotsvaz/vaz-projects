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

useradd -rms /usr/bin/nologin ${user}
cd /home/${user}/
sudo -Eu ${user} bash << EOF
curl -s ${repositorySnapshot} | tar -xz --strip-components 1

aws s3 sync s3://${bucket}/deployment/ deployment/ --no-progress

mkdir deployment/logs/
EOF

systemctl enable /home/${user}/server/systemdUnits/*



# Start Services
#---------------------------------------
systemctl start dehydrated.timer nginx



echo 'Finished Instance Configuration Script.'