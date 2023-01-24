# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource aws_vpc main {
	cidr_block = "10.0.0.0/16"
	assign_generated_ipv6_cidr_block = true
	enable_dns_hostnames = true
	
	tags = {
		Name: "${local.project_name} VPC"
	}
}


resource aws_vpc_dhcp_options main {
	domain_name_servers = [ "AmazonProvidedDNS" ]
	
	tags = {
		Name: "${local.project_name} DHCP Options"
	}
}


resource aws_vpc_dhcp_options_association main {
	vpc_id = aws_vpc.main.id
	dhcp_options_id = aws_vpc_dhcp_options.main.id
}


resource aws_internet_gateway main {
	vpc_id = aws_vpc.main.id
	
	tags = {
		Name: "${local.project_name} Internet Gateway"
	}
}


resource aws_default_route_table main {
	default_route_table_id = aws_vpc.main.default_route_table_id
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.main.id
	}
	
	route {
		ipv6_cidr_block = "::/0"
		gateway_id = aws_internet_gateway.main.id
	}
	
	tags = {
		Name: "${local.project_name} Route Table"
	}
}


resource aws_subnet subnet_c {
	vpc_id = aws_vpc.main.id
	availability_zone = "sa-east-1c"
	cidr_block = cidrsubnet( aws_vpc.main.cidr_block, 8, 3 )
	ipv6_cidr_block = cidrsubnet( aws_vpc.main.ipv6_cidr_block, 8, 3 )
	map_public_ip_on_launch = true
	assign_ipv6_address_on_creation = true
	
	depends_on = [ aws_vpc_dhcp_options_association.main ]	# Block instance creation before DHCP options is ready.
	
	tags = {
		Name: "${local.project_name} Subnet C"
	}
}


resource aws_default_network_acl main {
	default_network_acl_id = aws_vpc.main.default_network_acl_id
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
	vpc_id = aws_vpc.main.id
	
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