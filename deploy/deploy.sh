#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Parameters.
environment="${1}" 
command="${2}"


# Always run on project root.
cd "$(dirname "${BASH_SOURCE[0]}")/../"


# Manually set GitLab CI/CD variables when running locally.
# Use a function to allow local variables and the use of different
# environments on the same script call.
function setupEnvironment
{
	local environment="${1}"
	
	if [[ ${GITLAB_CI} ]]; then
		echo 'Running in CI/CD.'
		
		terraformAutoApprove='-auto-approve'
		
		set -o xtrace
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
	
	# Export only the following variables.
	local -
	set -o allexport
	
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
	
	# Terraform variables.
	TF_VAR_environment="${environment}"
	TF_VAR_repository_snapshot="${repositorySnapshot}"
	TF_VAR_application_image="${applicationImage}"
}


setupEnvironment ${environment}


# Check if sourced.
if [[ ${BASH_SOURCE[0]} != ${0} ]]; then
    echo 'Environment setup complete.'
	
	return
fi


# Abort on error, but not when sourcing.
set -o errexit



# 
# Build AMI with Packer.
#-------------------------------------------------------------------------------
function buildAmi
{
	cd deploy/packer/
	
	packer init .
	packer build .
}



# 
# Build builder AMI with Packer.
#-------------------------------------------------------------------------------
function buildBuilderAmi
{
	cd deploy/packer/
	
	packer init .
	packer build -var 'ami_name=VAZ Projects Builder AMI' -var 'playbook=builderAmiPlaybook.yaml' -var 'disk_size=3' .
}



# 
# Deploy environment-specific AWS resources.
#-------------------------------------------------------------------------------
function deployEnvironment
{
	cd "${terraformRoot}/environment/"
	terraform init -reconfigure
	terraform plan -out "${terraformPlan}"
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
	terraform init -reconfigure
	terraform destroy ${terraformAutoApprove}
}



# 
# Deploy AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function deployGlobal
{
	cd "${terraformRoot}/global/"
	terraform init -reconfigure
	terraform apply ${terraformAutoApprove}
}



# 
# Destroy AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function destroyGlobal
{
	cd "${terraformRoot}/global/"
	terraform init -reconfigure
	terraform destroy ${terraformAutoApprove}
}



# 
# Run command.
#-------------------------------------------------------------------------------
if [[ ${command} =~ ^(buildAmi|buildBuilderAmi|deployEnvironment|destroyEnvironment|deployGlobal|destroyGlobal)$ ]]; then
	${command}
else
	echo "Invalid command: ${command}"
	
	exit 1
fi