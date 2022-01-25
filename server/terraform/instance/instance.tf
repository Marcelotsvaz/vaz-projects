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


locals {
	app_server_root_volume_tags = merge( { Name = "${local.projectName} Server Root" }, local.default_tags )
}


resource "aws_spot_instance_request" "app_server" {
	ami = data.aws_ami.arch_linux.id
	instance_type = "t3a.small"
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [ aws_default_security_group.security_group.id ]
	iam_instance_profile = aws_iam_instance_profile.instance_profile.name
	user_data_base64 = var.user_data
	ebs_optimized = true
	instance_interruption_behavior = "stop"
	wait_for_fulfillment = true
	
	root_block_device {
		volume_size = 5
		
		tags = local.app_server_root_volume_tags
	}
	
	tags = { Name = "${local.projectName} Server Spot Request" }
}


resource "aws_ec2_tag" "app_server_tags" {
	resource_id = aws_spot_instance_request.app_server.spot_instance_id
	
	for_each = merge( { Name = "${local.projectName} Server" }, local.default_tags )
	key = each.key
	value = each.value
}


resource "aws_ec2_tag" "app_server_root_volume_tags" {
	resource_id = aws_spot_instance_request.app_server.root_block_device.0.volume_id
	
	for_each = local.app_server_root_volume_tags
	key = each.key
	value = each.value
}