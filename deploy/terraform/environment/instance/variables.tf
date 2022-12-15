# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Name.
#-------------------------------------------------------------------------------
variable "name" {
	description = "Name of the instance."
	type = string
}

variable "identifier" {
	description = "Unique identifier used in resources that need a unique name."
	type = string
}

variable "hostname" {
	description = "Hostname for private hosted zone A record."
	type = string
}

variable "prefix" {
	description = "Unique prefix used in resources that need a globally unique name."
	type = string
}


# Configuration.
#-------------------------------------------------------------------------------
variable "ami_id" {
	description = "AMI ID."
	type = string
}

variable "instance_type" {
	description = "Instance type. E.g. `t3.micro`."
	type = string
}

variable "root_volume_size" {
	description = "Size of the root volume in GB."
	type = number
}


# Network.
#-------------------------------------------------------------------------------
variable "subnet_id" {
	description = "VPC subnet ID."
	type = string
}

variable "ipv6_address_count" {
	description = "IPv6 address count."
	type = number
	default = 0
}

variable "vpc_security_group_ids" {
	description = "Set of security group IDs"
	type = set( string )
}

variable "private_hosted_zone" {
	description = "Private hosted zone for instance hostname A record."
	type = object( { arn = string, zone_id = string, name = string } )
}


# Environment.
#-------------------------------------------------------------------------------
variable "role_policy" {
	description = "Policy for the IAM instance profile."
	type = object( { json = string } )
}

variable "environment" {
	description = "Environment variables."
	type = map( string )
	default = {}
}


# Tags.
#-------------------------------------------------------------------------------
variable "default_tags" {
	description = "Tags to be applied to all resources."
	type = map( string )
	default = {}
}