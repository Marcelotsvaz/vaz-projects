# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# VPC
#-------------------------------------------------------------------------------
resource aws_vpc main {
	cidr_block = "10.0.0.0/16"
	assign_generated_ipv6_cidr_block = true
	enable_dns_hostnames = true
	
	tags = {
		Name = "${var.name} VPC"
	}
}


resource aws_vpc_dhcp_options main {
	domain_name = var.domain_name
	domain_name_servers = [ "AmazonProvidedDNS" ]
	
	tags = {
		Name = "${var.name} DHCP Options"
	}
}


resource aws_vpc_dhcp_options_association main {
	vpc_id = aws_vpc.main.id
	dhcp_options_id = aws_vpc_dhcp_options.main.id
}


resource aws_internet_gateway main {
	vpc_id = aws_vpc.main.id
	
	tags = {
		Name = "${var.name} Internet Gateway"
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
		Name = "${var.name} Route Table"
	}
}



# 
# Subnets
#-------------------------------------------------------------------------------
data aws_availability_zones main {
	
}


locals {
	availability_zone_letters = [
		for zone in data.aws_availability_zones.main.names :
		upper( trimprefix( zone, data.aws_availability_zones.main.id ) )
	]
}


resource aws_subnet main {
	count = length( data.aws_availability_zones.main.names )
	
	vpc_id = aws_vpc.main.id
	availability_zone = data.aws_availability_zones.main.names[count.index]
	cidr_block = cidrsubnet( aws_vpc.main.cidr_block, 8, count.index )
	ipv6_cidr_block = cidrsubnet( aws_vpc.main.ipv6_cidr_block, 8, count.index )
	map_public_ip_on_launch = true
	assign_ipv6_address_on_creation = true
	
	# Block instance creation before DHCP options is ready.
	depends_on = [ aws_vpc_dhcp_options_association.main ]
	
	tags = {
		Name = "${var.name} Subnet ${local.availability_zone_letters[count.index]}"
	}
}



# 
# Security
#-------------------------------------------------------------------------------
resource aws_default_network_acl main {
	default_network_acl_id = aws_vpc.main.default_network_acl_id
	subnet_ids = aws_subnet.main[*].id
	
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
		Name = "${var.name} ACL"
	}
}