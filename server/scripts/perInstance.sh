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
hostnamectl set-hostname ${hostname}

echo ${sshKey} > ~marcelotsvaz/.ssh/authorized_keys

useradd -rms /usr/bin/nologin ${user}

echo '::1 memcached' >> /etc/hosts	# TODO: Remove this.

cd /home/${user}/

sudo -Eu ${user} bash << EOF
aws s3 cp s3://${bucket}/source.tar.gz - | tar -xz
aws s3 sync s3://${bucket}/deployment/ deployment/ --no-progress

mkdir deployment/{logs,static}/
EOF

systemctl enable /home/${user}/server/systemdUnits/*



# Django Setup
#---------------------------------------
sudo -Eu ${user} bash << EOF
python -m venv deployment/env/
source deployment/env/bin/activate

pip install pip wheel --upgrade
CPUCOUNT=1 pip install -r requirements/${environment}.txt	# TODO: Fix uWSGI install bug.

vazProjects/manage.py migrate --no-input
EOF



# Start Services
#---------------------------------------
systemctl start backup.timer dehydrated.timer nginx memcached uwsgi



echo 'Finished Instance Configuration Script.'