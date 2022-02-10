#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



output "id" {
	description = ""
	value = aws_spot_instance_request.instance.spot_instance_id
}