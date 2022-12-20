# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "external" "user_data" {
	program = [
		"bash",
		"-c",
		<<-EOF
			input_dir='${abspath( var.input_dir )}'
			output_dir='${abspath( var.output_dir )}'
			template_extension='.tftpl'
			
			files=( ${join( " ", [ for file in var.files : "'${file}'" ] )} )
			
			templates=( ${join( " ", [ for template in var.templates : "'${template}'" ] )} )
			contents=( ${join( " ", [ for content in local.contents : "'${content}'" ] )} )
			
			environment_file='${var.environment_file}'
			environment_rendered='${local.environment_rendered}'
			
			
			mkdir -p "$${output_dir}"
			templates=( "$${templates[@]%$${template_extension}}" )	# Remove extension.
			
			for index in $${!templates[@]}; do
				echo $${contents[$index]} | base64 -d > "$${output_dir}/$${templates[$index]}"
				chmod --reference="$${input_dir}/$${templates[$index]}$${template_extension}" "$${output_dir}/$${templates[$index]}"
			done
			
			echo $${environment_rendered} | base64 -d > "$${output_dir}/$${environment_file}"
			
			content_base64=$(tar												\
				-cz																\
				--mtime='UTC 2000-01-01'										\
				--owner=root													\
				--group=root													\
				-C "$${input_dir}" "$${files[@]}"								\
				-C "$${output_dir}" "$${templates[@]}" "$${environment_file}"	\
				| base64 -w 0
			)
			
			echo '{"content_base64":"'$${content_base64}'"}'
		EOF
	]
}