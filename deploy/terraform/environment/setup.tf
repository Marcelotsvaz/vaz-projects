# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.25"
		}
	}
	
	backend "http" {
		lock_method = "POST"
		unlock_method = "DELETE"
		retry_wait_min = 5
	}
	
	required_version = ">= 0.14.9"
}


provider "aws" {
	region = local.region
	
	default_tags { tags = local.default_tags }
}


provider "aws" {
	alias = "us_east_1"
	
	region = "us-east-1"
	
	default_tags { tags = local.default_tags }
}