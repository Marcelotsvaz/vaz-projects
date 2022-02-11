#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "name" {
	description = ""
	type = string
}

variable "instance_type" {
	description = ""
	type = string
}

variable "subnet_id" {
	description = ""
	type = string
}

variable "vpc_security_group_ids" {
	description = ""
	type = set( string )
}

variable "private_hosted_zone" {
	description = ""
}

variable "hostname" {
	description = ""
	type = string
}

variable "role_name" {
	description = ""
	type = string
}

variable "role_policy" {
	description = ""
}

variable "root_volume_size" {
	description = ""
	type = number
}

variable "user_data_base64" {
	description = ""
	type = string
	default = ""
}

variable "default_tags" {
	description = ""
	type = map( string )
	default = {}
}