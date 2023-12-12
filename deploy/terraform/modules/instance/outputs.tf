# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



output id {
	description = "Instance ID."
	value = data.aws_instance.main.id
}

output ip_address {
	description = "Instance IPv4 address."
	value = data.aws_instance.main.public_ip
}

output ipv6_address {
	description = "Instance IPv6 address."
	value = one( data.aws_instance.main.ipv6_addresses )
}

output instance_profile_role_arn {
	description = "Instance IAM Role ARN."
	value = aws_iam_role.main.arn
}