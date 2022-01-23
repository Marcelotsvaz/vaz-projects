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
source "deployment/local.sh"
source "server/scripts/${1}.sh"

# Terraform variables.
terraformRoot='server/deploy'
TF_DATA_DIR='../../deployment/terraform'
TF_IN_AUTOMATION='True'



# Setup Terraform.
function terraformInit()
{
	terraformUrl="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${environment}"
	
	terraform -chdir=${terraformRoot} init -reconfigure				\
		-backend-config="address=${terraformUrl}"					\
		-backend-config="lock_address=${terraformUrl}/lock"			\
		-backend-config="unlock_address=${terraformUrl}/lock"		\
		-backend-config="username=${gitlabUser:-gitlab-ci-token}"	\
		-backend-config="password=${CI_JOB_TOKEN}"
}



if [[ ${2} = 'uploadFiles' ]]; then
	# Source upload.
	git archive HEAD |								\
	tar -f - --wildcards --delete '**/static/**' |	\
	gzip |											\
	aws s3 cp - s3://${bucket}/${environment}/source.tar.gz
	
	# Upload static files.
	server/scripts/less.sh
	vazProjects/manage.py collectstatic --ignore '*/src/*' --no-input
	
	# Invalidade static files cache.
	aws cloudfront create-invalidation --distribution-id ${cloudfrontId} --paths '/*'
elif [[ ${2} = 'launchInstance' ]]; then
	userData=$(cd server/scripts/ && tar -cz per*.sh ${environment}.sh --transform="s/${environment}.sh/environment.sh/" | base64 -w 0 | base64 -w 0)
	
	terraformInit
	terraform -chdir=${terraformRoot} apply	\
		-auto-approve						\
		-var="environment=${environment}"	\
		-var="user_data=${userData}"
elif [[ ${2} = 'terminateInstance' ]]; then
	terraformInit
	terraform -chdir=${terraformRoot} destroy	\
		-auto-approve							\
		-var="environment=${environment}"
else
	exit 1
fi