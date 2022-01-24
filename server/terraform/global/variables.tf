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
	environmentName = title( var.environment )
	default_tags = {
		Project = "VAZ Projects"
		Environment = var.environment
		"Environment Name" = local.environmentName
	}
}