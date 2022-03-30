# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "name" {
	description = "Name of the instance."
	type = string
}

variable "unique_identifier" {
	description = "Unique prefix to be used in IAM role and instance profile names."
	type = string
}

variable "instance_type" {
	description = "Instance type. E.g. `t3.micro`."
	type = string
}

variable "subnet_id" {
	description = "VPC Subnet ID."
	type = string
}

variable "ipv6_address_count" {
	description = "IPv6 address count."
	type = number
	default = 1
}

variable "vpc_security_group_ids" {
	description = "Set of security group IDs"
	type = set( string )
}

variable "private_hosted_zone" {
	description = "Private hosted zone for instance hostname A record."
	type = object( { zone_id = string, name = string } )
}

variable "hostname" {
	description = "Hostname for private hosted zone A record."
	type = string
}

variable "role_policy" {
	description = "Policy for the IAM instance profile."
	type = object( { json = string } )
}

variable "root_volume_size" {
	description = "Size of the root volume in GB."
	type = number
}

variable "user_data_base64" {
	description = "User data, base64 encoded."
	type = string
	default = ""
}

variable "default_tags" {
	description = "Tags to be applied to all resources."
	type = map( string )
	default = {}
}