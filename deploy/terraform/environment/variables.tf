# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "environment" {
	type = string
	description = "Deployment environment."
}


variable "repository_snapshot" {
	type = string
	description = "Link to Git repository containing application code."
}


variable "application_image" {
	type = string
	description = "Application Docker image."
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