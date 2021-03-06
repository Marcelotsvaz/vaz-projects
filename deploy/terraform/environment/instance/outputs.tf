# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



output "id" {
	description = "Instance ID."
	value = aws_spot_instance_request.instance.spot_instance_id
}

output "ipv6_address" {
	description = "Instance IPv6 address."
	value = aws_spot_instance_request.instance.ipv6_addresses[0]
}