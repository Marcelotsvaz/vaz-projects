#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Activate Python virtual env, if there is one.
source 'deployment/env/bin/activate'

# Export variables, abort on error end echo commands.
set -aex

# Load environment variables.
source "server/scripts/${1}.sh"



if [[ ${2} = 'uploadFiles' ]]; then
	# Source upload.
	git archive HEAD |								\
	tar -f - --wildcards --delete '**/static/**' |	\
	gzip |											\
	aws s3 cp - s3://${bucket}/${environment}/source.tar.gz
	
	# Upload static files.
	server/scripts/less.sh
	vazProjects/manage.py collectstatic --ignore */src/* --no-input
	
	# Invalidade static files cache.
	aws cloudfront create-invalidation --distribution-id ${cloudfrontId} --paths '/*'
elif [[ ${2} = 'launchInstance' ]]; then
	userData=$(cd server/scripts/ && tar -cz per*.sh ${environment}.sh --transform="s/${environment}.sh/environment.sh/" | base64 -w 0 | base64 -w 0)
	
	terraform -chdir=server/deploy apply	\
		-auto-approve						\
		-var="environment=${environment}"	\
		-var="user_data=${userData}"
elif [[ ${2} = 'terminateInstance' ]]; then
	terraform -chdir=server/deploy destroy	\
		-auto-approve						\
		-var="environment=${environment}"
else
	exit -1
fi