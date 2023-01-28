# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



output id {
	description = "Instance ID."
	value = data.aws_instance.main.id
}

output ipv6_address {
	description = "Instance IPv6 address."
	value = one( data.aws_instance.main.ipv6_addresses )
}