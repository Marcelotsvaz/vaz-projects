# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "files" {
	description = "Raw files that will be added to the archive."
	type = set( string )
}


variable "templates" {
	description = "Templates that will be rendered and added to the archive."
	type = map( string )
}


variable "context" {
	description = "Context for templates."
	type = map( string )
}


variable "input_dir" {
	description = "Raw file and template location."
	type = string
	default = "."
}


variable "output_dir" {
	description = "Directory where rendered templates will be saved."
	type = string
	default = "/tmp/terraform"
}