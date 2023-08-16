#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



echo 'Starting Instance Configuration Script...'



# Script Setup
#---------------------------------------
set -o errexit



# System Setup
#---------------------------------------
hostnamectl set-hostname ${hostname}

useradd -rms /usr/bin/nologin ${user}
cd /home/${user}/
sudo -u ${user} bash <<- EOF
	curl --silent ${repositorySnapshot} | tar -xz --strip-components 1
	aws s3 sync s3://${bucket}/deployment/ deployment/ --no-progress
	chmod -R go= deployment/secrets.env deployment/tls/
EOF

cd loadBalancer/
docker compose up --detach --quiet-pull

systemctl enable /home/${user}/loadBalancer/systemdUnits/*



# Start Services
#---------------------------------------
systemctl start dehydrated.timer



echo 'Finished Instance Configuration Script.'