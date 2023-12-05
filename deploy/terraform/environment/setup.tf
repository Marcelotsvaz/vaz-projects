# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.57"
		}
		
		archive = {
			source = "hashicorp/archive"
			version = "~> 2.3"
		}
		
		external = {
			source = "hashicorp/external"
			version = "~> 2.2"
		}
		
		null = {
			source = "hashicorp/null"
			version = "~> 3.2"
		}
	}
	
	backend http {
		lock_method = "POST"
		unlock_method = "DELETE"
	}
	
	required_version = ">= 1.3.6"
}


provider aws {
	region = local.region
	
	default_tags { tags = local.default_tags }
}


# For aws_acm_certificate.cloudfront.
provider aws {
	alias = "global"
	
	region = "us-east-1"
	
	default_tags { tags = local.default_tags }
}