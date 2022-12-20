#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Export variables and abort on error.
set -ae


# Parameters.
command=${1}
environment=${2}


# Variables.
if [[ "${GITLAB_CI}" ]]; then	# Running in GitLab CI/CD.
	echo 'Running in CI/CD.'
	
	commitSha="${CI_COMMIT_SHA}"
	terraformAutoApprove='-auto-approve'
	
	set -x	# Echo commands.
else
	echo 'Running outside CI/CD.'
	
	commitSha="$(git rev-parse remotes/gitlab/production)"	# TODO: Get PR branch when support for multiple staging environments is implemented.
	applicationImage="registry.gitlab.com/marcelotsvaz/vaz-projects/application:${commitSha}"
fi

TF_IN_AUTOMATION='True'
TF_DATA_DIR='../../../deployment/terraform'
terraformRoot='deploy/terraform'
terraformPlan=${TF_DATA_DIR}/../terraformPlan.cache
terraformChanges=${TF_DATA_DIR}/../terraformChanges.json
repositorySnapshot="https://gitlab.com/marcelotsvaz/vaz-projects/-/archive/${commitSha}/vaz-projects.tar.gz"



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
	
	if [[ ! "${terraformAutoApprove}" ]]; then
		read -p "Do you want to perform these actions? " approved
		
		if [[ "${approved}" != 'yes' ]]; then
			exit 1
		fi
	fi
	
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
		-var="environment=${environment}"					\
		-var="repository_snapshot=${repositorySnapshot}"	\
		-var="application_image=${applicationImage}"		\
		${terraformAutoApprove}
}



# 
# Deploy AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function deployGlobal()
{
	cd ${terraformRoot}/global
	terraformInit global
	terraform apply ${terraformAutoApprove}
}



# 
# Destroy AWS infrastructure common to all environments.
#-------------------------------------------------------------------------------
function destroyGlobal()
{
	cd ${terraformRoot}/global
	terraformInit global
	terraform destroy ${terraformAutoApprove}
}



# 
# Run command.
#-------------------------------------------------------------------------------
if [[ "${command}" =~ ^(deployEnvironment|destroyEnvironment|deployGlobal|destroyGlobal)$ ]]; then
	${command}
else
	echo 'Invalid command.'
	
	exit 1
fi