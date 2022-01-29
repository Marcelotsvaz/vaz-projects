#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "files" {
	description = "Raw files that will be added to the archive."
	type = set( string )
}


variable "templated_files" {
	description = "Templated files that will be added to the archive."
	type = set( string )
}


variable "context" {
	description = "Context for templated files."
	type = map( any )
}


variable "working_dir" {
	description = "Working directory."
	type = string
	default = "."
}


variable "temp_dir" {
	description = "Directory where rendered templates will be temporarily saved."
	type = string
	default = "/tmp/terraform"
}