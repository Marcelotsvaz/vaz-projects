#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Export variables, abort on error end echo commands.
set -aex

# Setup environment when running outside CI.
if [[ ${3} = 'local' ]]; then
	source 'deployment/env/bin/activate'
	source 'deployment/local.sh'
fi

# Load environment variables.
source "server/scripts/${2}.sh"

# Terraform variables.
terraformRoot='server/terraform'
TF_DATA_DIR='../../../deployment/terraform'
TF_IN_AUTOMATION='True'



# 
# Setup Terraform with specified state.
#-------------------------------------------------------------------------------
function terraformInit()
{
	local stateName=${1}
	
	terraformUrl="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/${stateName}"
	
	terraform init -reconfigure										\
		-backend-config="address=${terraformUrl}"					\
		-backend-config="lock_address=${terraformUrl}/lock"			\
		-backend-config="unlock_address=${terraformUrl}/lock"		\
		-backend-config="username=${gitlabUser:-gitlab-ci-token}"	\
		-backend-config="password=${CI_JOB_TOKEN}"
}



# 
# Setup AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function setupAws()
{
	cd ${terraformRoot}/global
	terraformInit global
	terraform apply		\
		-auto-approve	\
		-var="environment=global"
}



# 
# Upload static files and app source to S3.
#-------------------------------------------------------------------------------
function uploadFiles()
{
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
}



# 
# Launch the instance.
#-------------------------------------------------------------------------------
function launchInstance()
{
	userData=$(cd server/scripts/ && tar -cz per*.sh ${environment}.sh --transform="s/${environment}.sh/environment.sh/" | base64 -w 0 | base64 -w 0)
	
	cd ${terraformRoot}/instance
	terraformInit ${environment}
	terraform apply							\
		-auto-approve						\
		-var="environment=${environment}"	\
		-var="user_data=${userData}"
}



# 
# Terminate the instance.
#-------------------------------------------------------------------------------
function terminateInstance()
{
	cd ${terraformRoot}/instance
	terraformInit ${environment}
	terraform destroy							\
		-auto-approve							\
		-var="environment=${environment}"
}



# 
# Run command.
#-------------------------------------------------------------------------------
if [[ ${1} = 'setupAws' ]]; then
	setupAws
elif [[ ${1} = 'uploadFiles' ]]; then
	uploadFiles
elif [[ ${1} = 'launchInstance' ]]; then
	launchInstance
elif [[ ${1} = 'terminateInstance' ]]; then
	terminateInstance
else
	exit 1
fi