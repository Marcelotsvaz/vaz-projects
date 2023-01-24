# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource aws_vpc vpc {
	cidr_block = "10.0.0.0/16"
	assign_generated_ipv6_cidr_block = true
	enable_dns_hostnames = true
	
	tags = {
		Name: "${local.project_name} VPC"
	}
}


resource aws_vpc_dhcp_options dhcp_options {
	domain_name = aws_route53_zone.private.name
	domain_name_servers = [ "AmazonProvidedDNS" ]
	
	tags = {
		Name: "${local.project_name} DHCP Options"
	}
}


resource aws_vpc_dhcp_options_association dns_resolver {
	vpc_id = aws_vpc.vpc.id
	dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
}


resource aws_internet_gateway gateway {
	vpc_id = aws_vpc.vpc.id
	
	tags = {
		Name: "${local.project_name} Internet Gateway"
	}
}


resource aws_default_route_table route_table {
	default_route_table_id = aws_vpc.vpc.default_route_table_id
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.gateway.id
	}
	
	route {
		ipv6_cidr_block = "::/0"
		gateway_id = aws_internet_gateway.gateway.id
	}
	
	tags = {
		Name: "${local.project_name} Route Table"
	}
}


resource aws_subnet subnet_c {
	vpc_id = aws_vpc.vpc.id
	availability_zone = "sa-east-1c"
	cidr_block = cidrsubnet( aws_vpc.vpc.cidr_block, 8, 3 )
	ipv6_cidr_block = cidrsubnet( aws_vpc.vpc.ipv6_cidr_block, 8, 3 )
	map_public_ip_on_launch = true
	assign_ipv6_address_on_creation = true
	
	depends_on = [ aws_vpc_dhcp_options_association.dns_resolver ]	# Block instance creation before DHCP options is ready.
	
	tags = {
		Name: "${local.project_name} Subnet C"
	}
}


resource aws_default_network_acl acl {
	default_network_acl_id = aws_vpc.vpc.default_network_acl_id
	subnet_ids = [ aws_subnet.subnet_c.id ]
	
	ingress {
		rule_no = 100
		protocol = "all"
		from_port = 0
		to_port = 0
		cidr_block = "0.0.0.0/0"
		action = "allow"
	}
	
	ingress {
		rule_no = 101
		protocol = "all"
		from_port = 0
		to_port = 0
		ipv6_cidr_block = "::/0"
		action = "allow"
	}
	
	egress {
		rule_no = 100
		protocol = "all"
		from_port = 0
		to_port = 0
		cidr_block = "0.0.0.0/0"
		action = "allow"
	}
	
	egress {
		rule_no = 101
		protocol = "all"
		from_port = 0
		to_port = 0
		ipv6_cidr_block = "::/0"
		action = "allow"
	}
	
	tags = {
		Name: "${local.project_name} ACL"
	}
}


resource aws_default_security_group common {
	vpc_id = aws_vpc.vpc.id
	
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
		from_port = 8080
		to_port = 8080
		self = true
	}
	
	tags = {
		Name: "${local.project_name} Common Security Group"
	}
}


resource aws_security_group public {
	vpc_id = aws_vpc.vpc.id
	
	ingress {
		description = "NGINX - HTTPS"
		protocol = "tcp"
		from_port = 443
		to_port = 443
		cidr_blocks = [ "0.0.0.0/0" ]
		ipv6_cidr_blocks = [ "::/0" ]
	}
	
	ingress {
		description = "NGINX - HTTP"
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
		Name: "${local.project_name} Public Security Group"
	}
}


resource aws_security_group private {
	vpc_id = aws_vpc.vpc.id
	
	ingress {
		description = "uWSGI"
		protocol = "tcp"
		from_port = 3031
		to_port = 3031
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
		Name: "${local.project_name} Private Security Group"
	}
}