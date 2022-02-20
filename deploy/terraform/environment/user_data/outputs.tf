# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



output "content_base64" {
	description = "Input files, archived with tar, compressed with gzip and base64 encoded."
	value = data.external.user_data.result.content_base64
}