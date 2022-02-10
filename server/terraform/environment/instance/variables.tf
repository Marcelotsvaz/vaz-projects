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

variable "iam_instance_profile" {
	description = ""
	type = string
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