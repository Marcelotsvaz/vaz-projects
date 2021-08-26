#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



echo 'Starting Instance Configuration Script...'



# Script Setup
########################################
set -e	# Abort on error.
export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')



# System Setup
########################################
hostnamectl set-hostname ${hostname}

echo ${sshKey} > ~marcelotsvaz/.ssh/authorized_keys

useradd -rm -s /usr/bin/nologin ${user}

echo '::1 memcached' >> /etc/hosts	# TODO: Remove this.

cd /home/${user}/

aws s3 cp s3://${bucket}/${environment}/source.tar.zst - | sudo -u ${user} tar -x --zstd
sudo -u ${user} aws s3 sync s3://${bucket}/${environment}/deployment/ deployment/ --no-progress

sudo -u ${user} mkdir deployment/{logs,static}/

systemctl enable /home/${user}/server/systemdUnits/*



# Django Setup
########################################
sudo -EHu ${user} bash << 'EOF'
python -m venv deployment/env
source deployment/env/bin/activate

pip install pip wheel --upgrade
pip install -r requirements/${environment}.txt

vazProjects/manage.py migrate --no-input
EOF



# Start Services
########################################
systemctl start backup.timer dehydrated.timer nginx memcached uwsgi



echo 'Finished Instance Configuration Script.'