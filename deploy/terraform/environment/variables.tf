# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "environment" {
	description = "Deployment environment."
	type = string
}


variable "repository_snapshot" {
	description = "Link to Git repository archive containing application code."
	type = string
}


variable "application_image" {
	description = "Application Docker image."
	type = string
}



locals {
	project_name = "VAZ Projects"
	project_code = "vazProjects"
	environment_name = title( var.environment )
	
	domain = var.environment == "production" ? "vazprojects.com" : "${var.environment}.vazprojects.com"
	static_files_domain = "static-files.${local.domain}"
	monitoring_domain = "monitoring.${local.domain}"
	private_domain = "private.${local.domain}"
	
	region = "sa-east-1"
	default_tags = {
		Project = local.project_name
		Environment = var.environment
		"Environment Name" = local.environment_name
	}
}