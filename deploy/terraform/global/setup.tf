# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.48"
		}
	}
	
	backend http {
		lock_method = "POST"
		unlock_method = "DELETE"
		retry_wait_min = 5
	}
	
	required_version = ">= 1.3.6"
}


provider aws {
	region = local.region
	
	default_tags { tags = local.default_tags }
}