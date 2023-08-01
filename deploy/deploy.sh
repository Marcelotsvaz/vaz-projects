#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Parameters.
environment="${1}" 
command="${2}"


# Manually set GitLab CI/CD variables when running locally.
# Use a function to allow local variables and the use of different
# environments on the same script call.
function setupEnvironment
{
	local environment="${1}"
	
	if [[ ${GITLAB_CI} ]]; then
		echo 'Running in CI/CD.'
		
		terraformAutoApprove='-auto-approve'
		
		set -x	# Echo commands.
	else
		echo 'Running outside CI/CD.'
		
		source 'deployment/local.env'
		
		# Get project path from git remote URL.
		local gitRemote=$(git rev-parse --abbrev-ref HEAD@{upstream} | cut -d '/' -f 1)
		local CI_PROJECT_PATH=$(git remote get-url ${gitRemote} | grep -Po '(?<=:)(.+)(?=\.git)')
		
		# Get latest upstream commit hash so we can set `repositorySnapshot` and `applicationImage`
		# to the same value that was deployed in CI/CD. Without it, local runs of Terraform will try
		# to update many resources that depend on those variables even though there was no actual
		# changes to the infrastructure.
		local CI_COMMIT_SHA=$(git rev-parse HEAD@{upstream})
		
		local CI_API_V4_URL='https://gitlab.com/api/v4'
		local CI_REGISTRY='registry.gitlab.com'
		local CI_PROJECT_URL="https://gitlab.com/${CI_PROJECT_PATH}"
		local CI_REGISTRY_IMAGE="${CI_REGISTRY}/${CI_PROJECT_PATH}"
		local applicationImage="${CI_REGISTRY_IMAGE}/application:${CI_COMMIT_SHA}"
	fi
	
	# Export the following variables.
	local -
	set -a
	
	# Terraform HTTP backend setup.
	TF_HTTP_ADDRESS="${CI_API_V4_URL}/projects/${CI_PROJECT_PATH/\//%2F}/terraform/state/${environment}"
	TF_HTTP_LOCK_ADDRESS="${TF_HTTP_ADDRESS}/lock"
	TF_HTTP_UNLOCK_ADDRESS="${TF_HTTP_ADDRESS}/lock"
	TF_HTTP_USERNAME="${terraformBackendUsername:-gitlab-ci-token}"
	TF_HTTP_PASSWORD="${terraformBackendPassword:-${CI_JOB_TOKEN}}"
	
	# Terraform setup.
	TF_DATA_DIR='../../../deployment/terraform'
	TF_IN_AUTOMATION='True'
	terraformRoot='deploy/terraform'
	terraformPlan="${TF_DATA_DIR}/../terraformPlan.cache"
	terraformChanges="${TF_DATA_DIR}/../terraformChanges.json"
	repositorySnapshot="${CI_PROJECT_URL}/-/archive/${CI_COMMIT_SHA}/vaz-projects.tar.gz"
}


setupEnvironment ${environment}


# Check if sourced.
if [[ ${BASH_SOURCE[0]} != ${0} ]]; then
    echo 'Environment setup complete.'
	
	return
fi


# Abort on error, but not when sourcing.
set -e



# 
# Prepare files for Packer.
#-------------------------------------------------------------------------------
function preparePacker
{
	# User data.
	tar -cz									\
		--mtime='UTC 2000-01-01'			\
		--owner=root						\
		--group=root						\
		-f ../../deployment/userData.tar.gz	\
		perInstance.sh
}



# 
# Build AMI with Packer.
#-------------------------------------------------------------------------------
function buildAmi
{
	cd deploy/packer/
	
	preparePacker
	packer build .
}



# 
# Build builder AMI with Packer.
#-------------------------------------------------------------------------------
function buildBuilderAmi
{
	cd deploy/packer/
	
	preparePacker
	packer build -var 'ami_name=VAZ Projects Builder AMI' -var 'playbook=builderAmiPlaybook.yaml' -var 'disk_size=3' .
}



# 
# Setup Terraform with specified state.
#-------------------------------------------------------------------------------
function terraformInit
{
	terraform init -reconfigure
}



# 
# Deploy environment-specific AWS resources.
#-------------------------------------------------------------------------------
function deployEnvironment
{
	cd "${terraformRoot}/environment/"
	terraformInit
	terraform plan											\
		-var="environment=${environment}"					\
		-var="repository_snapshot=${repositorySnapshot}"	\
		-var="application_image=${applicationImage}"		\
		-out "${terraformPlan}"
	terraform show -no-color "${terraformPlan}"																						\
		| sed -En 's/^Plan: ([0-9]+) to add, ([0-9]+) to change, ([0-9]+) to destroy\.$/{"create":\1,"update":\2,"delete":\3}/p'	\
		> "${terraformChanges}"
	
	if [[ ! ${terraformAutoApprove} ]]; then
		read -p 'Do you want to perform these actions? ' approved
		
		if [[ ${approved} != 'yes' ]]; then
			exit 1
		fi
	fi
	
	terraform apply "${terraformPlan}"
}



# 
# Destroy environment-specific AWS resources.
#-------------------------------------------------------------------------------
function destroyEnvironment
{
	cd "${terraformRoot}/environment/"
	terraformInit
	terraform destroy										\
		-var="environment=${environment}"					\
		-var="repository_snapshot=${repositorySnapshot}"	\
		-var="application_image=${applicationImage}"		\
		${terraformAutoApprove}
}



# 
# Deploy AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function deployGlobal
{
	cd "${terraformRoot}/global/"
	terraformInit
	terraform apply ${terraformAutoApprove}
}



# 
# Destroy AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function destroyGlobal
{
	cd "${terraformRoot}/global/"
	terraformInit
	terraform destroy ${terraformAutoApprove}
}



# 
# Run command.
#-------------------------------------------------------------------------------
if [[ ${command} =~ ^(buildAmi|buildBuilderAmi|deployEnvironment|destroyEnvironment|deployGlobal|destroyGlobal)$ ]]; then
	${command}
else
	echo 'Invalid command.'
	
	exit 1
fi