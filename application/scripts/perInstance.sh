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
	curl -s ${repositorySnapshot} | tar -xz --strip-components 1
	aws s3 cp s3://${bucket}/deployment/secrets.env deployment/ --no-progress
	chmod -R go= deployment/secrets.env
EOF

cd application/
docker compose --env-file ../deployment/secrets.env up --detach --quiet-pull



echo 'Finished Instance Configuration Script.'