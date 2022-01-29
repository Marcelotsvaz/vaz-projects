#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource "local_file" "templated_file" {
	for_each = var.templated_files
	
	filename = "${var.temp_dir}/${each.value}"
	content = templatefile( "${var.working_dir}/${each.value}", var.context )
}


data "external" "user_data" {
	working_dir = var.working_dir
	
	query = {
		files = join( " ", var.files )
		templated_files = join( " ", var.templated_files )
		temp_dir = var.temp_dir
	}
	
	program = [
		"bash",
		"-c",
		<<-EOF
			args=$(jq -r '[ .files, "-C", .temp_dir, .templated_files ] | join( " " )')
			
			content_base64=$(tar -cz $args | base64 -w 0)
			
			jq -n "{ content_base64: \"$content_base64\" }"
		EOF
	]
	
	depends_on = [ local_file.templated_file ]
}