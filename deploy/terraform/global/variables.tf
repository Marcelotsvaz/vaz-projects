# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "environment" {
	description = "Deployment environment."
	type = string
}



locals {
	project_name = "VAZ Projects"
	project_code = "vazProjects"
	environment_name = title( var.environment )
	region = "sa-east-1"
	
	domain = "vazprojects.com"
	
	default_tags = {
		Project = local.project_name
		Environment = var.environment
		"Environment Name" = local.environment_name
	}
}