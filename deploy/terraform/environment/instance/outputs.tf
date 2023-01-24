# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



output id {
	description = "Instance ID."
	value = data.aws_instance.instance.id
}

output ipv6_address {
	description = "Instance IPv6 address."
	value = one( data.aws_instance.instance.ipv6_addresses )
}