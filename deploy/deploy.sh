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

# Variables.
TF_IN_AUTOMATION='True'
TF_DATA_DIR='../../../deployment/terraform'
terraformRoot='deploy/terraform'
terraformPlan=${TF_DATA_DIR}/../terraformPlan.cache
terraformChanges=${TF_DATA_DIR}/../terraformChanges.json



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
	cd ${terraformRoot}/environment
	terraformInit ${environment}
	terraform plan											\
		-var="environment=${environment}"					\
		-var="repository_snapshot=${repositorySnapshot}"	\
		-var="application_image=${applicationImage}"		\
		-out ${terraformPlan}
	terraform show -no-color ${terraformPlan}																						\
		| sed -En 's/^Plan: ([0-9]+) to add, ([0-9]+) to change, ([0-9]+) to destroy\.$/{"create":\1,"update":\2,"delete":\3}/p'	\
		> ${terraformChanges}
	terraform apply ${terraformPlan}
}



# 
# Destroy environment-specific AWS resources.
#-------------------------------------------------------------------------------
function destroyEnvironment()
{
	cd ${terraformRoot}/environment
	terraformInit ${environment}
	terraform destroy										\
		-auto-approve										\
		-var="environment=${environment}"					\
		-var="repository_snapshot=${repositorySnapshot}"	\
		-var="application_image=${applicationImage}"
}



# 
# Run command.
#-------------------------------------------------------------------------------
if [[ "${command}" =~ ^(deployAws|destroyAws|deployEnvironment|destroyEnvironment)$ ]]; then
	${command}
else
	echo 'Invalid command.'
	
	exit 1
fi