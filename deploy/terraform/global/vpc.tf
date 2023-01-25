# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# VPC
#-------------------------------------------------------------------------------
module vpc {
	source = "../modules/vpc"
	
	name = local.project_name
}



# 
# Security
#-------------------------------------------------------------------------------
resource aws_default_security_group common {
	vpc_id = module.vpc.id
	
	egress {
		description = "All traffic"
		protocol = "all"
		from_port = 0
		to_port = 0
		cidr_blocks = [ "0.0.0.0/0" ]
		ipv6_cidr_blocks = [ "::/0" ]
	}
	
	ingress {
		description = "OpenSSH"
		protocol = "tcp"
		from_port = 22
		to_port = 22
		cidr_blocks = [ "0.0.0.0/0" ]
		ipv6_cidr_blocks = [ "::/0" ]
	}
	
	tags = {
		Name: "${local.project_name} Common Security Group"
	}
}