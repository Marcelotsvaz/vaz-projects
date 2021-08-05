#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Logs
#-------------------------------------------------------------------------------
cd /home/${user}/deployment/logs/
if [[ -s nginx-access.log ]]; then
	aws s3 cp nginx-access.log s3://${bucket}-logs/${environment}/nginx/nginx-access-$(date +'%Y-%m-%dT%H:%M').log --no-progress
	truncate -s 0 nginx-access.log
fi

if [[ -s nginx-error.log ]]; then
	aws s3 cp nginx-error.log s3://${bucket}-logs/${environment}/nginx/nginx-error-$(date +'%Y-%m-%dT%H:%M').log --no-progress
	truncate -s 0 nginx-error.log
fi


# Backup
#-------------------------------------------------------------------------------
aws s3 cp /home/${user}/deployment/utl.sqlite3 s3://${bucket}/${environment}/deployment/ --no-progress