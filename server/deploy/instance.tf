#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "aws_ami" "arch_linux" {
	most_recent = true
	owners = [ "self" ]
	
	filter {
		name = "name"
		values = [ "Arch Linux AMI" ]
	}
}


resource "aws_spot_instance_request" "app_server" {
	ami = data.aws_ami.arch_linux.id
	instance_type = "t3a.small"
	subnet_id = "subnet-0894058c2c5843be6"
	vpc_security_group_ids = [ "sg-0c3e4b6d598d9745f" ]
	iam_instance_profile = "vazProjectsStagingRole"
	user_data_base64 = var.user_data
	ebs_optimized = true
	instance_interruption_behavior = "stop"
	wait_for_fulfillment = true
	
	root_block_device { volume_size = 5 }
	
	tags = { Name = "VAZ Projects ${local.environmentName} Server Spot Request" }
}


data "aws_default_tags" "current" {}


resource "aws_ec2_tag" "app_server_tag" {
	resource_id = aws_spot_instance_request.app_server.spot_instance_id
	
	for_each = merge( { Name = "VAZ Projects ${local.environmentName} Server" }, data.aws_default_tags.current.tags )
	key = each.key
	value = each.value
}


resource "aws_ec2_tag" "app_server_volume_tag" {
	resource_id = aws_spot_instance_request.app_server.root_block_device.0.volume_id
	
	for_each = merge( { Name = "VAZ Projects ${local.environmentName} Server Root" }, data.aws_default_tags.current.tags )
	key = each.key
	value = each.value
}