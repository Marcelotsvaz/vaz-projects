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
	domain_name = local.private_domain
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
		description = "Node Exporter Metrics"
		protocol = "tcp"
		from_port = 9100
		to_port = 9100
		self = true
	}
	
	ingress {
		description = "Docker Engine Metrics"
		protocol = "tcp"
		from_port = 9323
		to_port = 9323
		self = true
	}
	
	ingress {
		description = "cAdvisor Metrics"
		protocol = "tcp"
		from_port = 9080
		to_port = 9080
		self = true
	}
	
	ingress {
		description = "Traefik Metrics"
		protocol = "tcp"
		from_port = 8080
		to_port = 8080
		self = true
	}
	
	tags = {
		Name = "${local.project_name} Common Security Group"
	}
}


resource aws_security_group public {
	vpc_id = module.vpc.id
	
	ingress {
		description = "Traefik - HTTPS"
		protocol = "tcp"
		from_port = 443
		to_port = 443
		cidr_blocks = [ "0.0.0.0/0" ]
		ipv6_cidr_blocks = [ "::/0" ]
	}
	
	ingress {
		description = "Traefik - HTTP"
		protocol = "tcp"
		from_port = 80
		to_port = 80
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
		Name = "${local.project_name} Public Security Group"
	}
}


resource aws_security_group private {
	vpc_id = module.vpc.id
	
	ingress {
		description = "uWSGI"
		protocol = "tcp"
		from_port = 8000
		to_port = 8000
		security_groups = [ aws_security_group.public.id ]
	}
	
	ingress {
		description = "PostgreSQL"
		protocol = "tcp"
		from_port = 5432
		to_port = 5432
		self = true
	}
	
	ingress {
		description = "Grafana - HTTP"
		protocol = "tcp"
		from_port = 80
		to_port = 80
		security_groups = [ aws_security_group.public.id ]
	}
	
	ingress {
		description = "Loki"
		protocol = "tcp"
		from_port = 3100
		to_port = 3100
		security_groups = [ aws_default_security_group.common.id ]
	}
	
	ingress {
		description = "OpenSSH"
		protocol = "tcp"
		from_port = 22
		to_port = 22
		security_groups = [ aws_security_group.public.id ]
	}
	
	tags = {
		Name = "${local.project_name} Private Security Group"
	}
}