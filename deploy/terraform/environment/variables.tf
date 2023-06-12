# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable environment {
	description = "Deployment environment."
	type = string
}


variable repository_snapshot {
	description = "Link to Git repository archive containing application code."
	type = string
}


variable application_image {
	description = "Application Docker image."
	type = string
}


variable highly_available {
	description = "Launch resources in a high availability configuration."
	type = bool
	default = false
}



locals {
	project_name = "VAZ Projects"
	project_code = "vazProjects"
	project_prefix = "${local.project_code}-${var.environment}"
	environment_name = title( var.environment )
	region = "sa-east-1"
	
	domain = var.environment == "production" ? "vazprojects.com" : "${var.environment}.vazprojects.com"
	static_files_domain = "static-files.${local.domain}"
	monitoring_domain = "monitoring.${local.domain}"
	private_domain = "private.${local.domain}"
	
	ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7gGmj7aRlkjoPKKM35M+dG6gMkgD9IEZl2UVp6JYPs VAZ Projects SSH Key"
	
	default_tags = {
		Project = local.project_name
		Environment = var.environment
		"Environment Name" = local.environment_name
	}
}