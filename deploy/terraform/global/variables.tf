# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



locals {
	project_name = "VAZ Projects"
	project_code = "vazProjects"
	region = "sa-east-1"
	
	domain = "vazprojects.com"
	
	default_tags = {
		Project = local.project_name
		Environment = "global"
		"Environment Name" = "Global"
	}
}