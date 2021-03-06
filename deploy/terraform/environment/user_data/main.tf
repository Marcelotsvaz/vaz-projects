# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource "local_file" "templated_file" {
	for_each = var.templates
	
	content = templatefile( "${var.input_dir}/${each.key}", var.context )
	filename = "${var.output_dir}/${each.value}"
}


data "external" "user_data" {
	query = {
		files = join( "#", var.files )
		templated_files = join( "#", [ for templated_file in var.templates : templated_file ] )
		input_dir = "${path.cwd}/${var.input_dir}"
		output_dir = "${path.cwd}/${var.output_dir}"
	}
	
	program = [
		"bash",
		"-c",
		<<-EOF
			args=$(jq -r '[ "-C", .input_dir, .files, "-C", .output_dir, .templated_files ] | join( "#" )')
			
			IFS='#'
			content_base64=$(tar -cz $args | base64 -w 0)
			
			jq -n "{ content_base64: \"$content_base64\" }"
		EOF
	]
	
	depends_on = [ local_file.templated_file ]
}