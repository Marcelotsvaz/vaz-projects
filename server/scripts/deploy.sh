#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Export variables, abort on error end echo commands.
set -aex

# Parameters.
command=${1}
environment=${2}
local=${3}

# Variables.
terraformRoot='server/terraform'
TF_DATA_DIR='../../../deployment/terraform'
TF_IN_AUTOMATION='True'

# Setup environment when running outside CI.
if [[ ${local} ]]; then
	source 'deployment/local.sh'
fi



# 
# Setup Terraform with specified state.
#-------------------------------------------------------------------------------
function terraformInit()
{
	local stateName=${1}
	local terraformUrl="https://gitlab.com/api/v4/projects/${CI_PROJECT_ID}/terraform/state/${stateName}"
	
	terraform init -reconfigure										\
		-backend-config="address=${terraformUrl}"					\
		-backend-config="lock_address=${terraformUrl}/lock"			\
		-backend-config="unlock_address=${terraformUrl}/lock"		\
		-backend-config="username=${gitlabUser:-gitlab-ci-token}"	\
		-backend-config="password=${CI_JOB_TOKEN}"
}



# 
# Deploy AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function deployAws()
{
	cd ${terraformRoot}/global
	terraformInit global
	terraform apply		\
		-auto-approve	\
		-var="environment=global"
}



# 
# Destroy AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function destroyAws()
{
	cd ${terraformRoot}/global
	terraformInit global
	terraform destroy	\
		-auto-approve	\
		-var="environment=global"
}



# 
# Deploy environment-specific AWS resources.
#-------------------------------------------------------------------------------
function deployEnvironment()
{
	cd ${terraformRoot}/instance
	terraformInit ${environment}
	terraform apply											\
		-auto-approve										\
		-var="environment=${environment}"					\
		-var="repository_snapshot=${repositorySnapshot}"	\
		-var="application_image=${applicationImage}"
}



# 
# Destroy environment-specific AWS resources.
#-------------------------------------------------------------------------------
function destroyEnvironment()
{
	cd ${terraformRoot}/instance
	terraformInit ${environment}
	terraform destroy										\
		-auto-approve										\
		-var="environment=${environment}"					\
		-var="repository_snapshot=${repositorySnapshot}"	\
		-var="application_image=${applicationImage}"
}



# 
# Upload static files and app source to S3.
#-------------------------------------------------------------------------------
# function uploadFiles()
# {
# 	# Upload static files.
# 	vazProjects/manage.py collectstatic --ignore '*/src/*' --no-input
	
# 	# Invalidade static files cache.
# 	aws cloudfront create-invalidation --distribution-id ${cloudfrontId} --paths '/*'
# }



# 
# Run command.
#-------------------------------------------------------------------------------
if [[ "${command}" =~ ^(deployAws|destroyAws|deployEnvironment|destroyEnvironment|uploadFiles)$ ]]; then
	${command}
else
	echo 'Invalid command.'
	
	exit 1
fi