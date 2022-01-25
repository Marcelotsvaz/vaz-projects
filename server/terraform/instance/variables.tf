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
	projectName = "VAZ Projects"
	environmentName = title( var.environment )
	default_tags = {
		Project = local.projectName
		Environment = var.environment
		"Environment Name" = local.environmentName
	}
}