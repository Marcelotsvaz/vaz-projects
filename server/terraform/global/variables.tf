#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "environment" {
	type = string
	description = "Deployment environment."
}



locals {
	projectName = "VAZ Projects"
	projectCode = "vazProjects"
	environmentName = title( var.environment )
	default_tags = {
		Project = local.projectName
		Environment = var.environment
		"Environment Name" = local.environmentName
	}
}