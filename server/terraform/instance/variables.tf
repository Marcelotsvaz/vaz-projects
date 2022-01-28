#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "environment" {
	type = string
	description = "Deployment environment."
}


variable "user_data" {
	type = string
	description = "EC2 user data (base64 encoded)."
	default = ""
}



locals {
	project_name = "VAZ Projects"
	project_code = "vazProjects"
	domain = "staging.vazprojects.com"
	environment_name = title( var.environment )
	region = "sa-east-1"
	default_tags = {
		Project = local.project_name
		Environment = var.environment
		"Environment Name" = local.environment_name
	}
}