#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Instances.
#-------------------------------------------------------------------------------
resource "aws_spot_instance_request" "app_server" {
	ami = data.aws_ami.arch_linux.id
	instance_type = var.instance_type
	subnet_id = var.subnet_id
	vpc_security_group_ids = var.vpc_security_group_ids
	iam_instance_profile = var.iam_instance_profile
	user_data_base64 = var.user_data_base64
	ebs_optimized = true
	instance_interruption_behavior = "stop"
	wait_for_fulfillment = true
	
	root_block_device {
		volume_size = var.root_volume_size
		
		tags = local.app_server_root_volume_tags
	}
	
	tags = {
		Name = "${var.name} Spot Request"
	}
}


data "aws_ami" "arch_linux" {
	most_recent = true
	owners = [ "self" ]
	
	filter {
		name = "name"
		values = [ "Arch Linux AMI" ]
	}
}



# 
# Tags.
#-------------------------------------------------------------------------------
locals {
	app_server_root_volume_tags = merge( { Name = "${var.name} Root Volume" }, var.default_tags )
}


resource "aws_ec2_tag" "app_server_tags" {
	resource_id = aws_spot_instance_request.app_server.spot_instance_id
	
	for_each = merge( { Name = var.name }, var.default_tags )
	key = each.key
	value = each.value
}


resource "aws_ec2_tag" "app_server_root_volume_tags" {
	resource_id = aws_spot_instance_request.app_server.root_block_device.0.volume_id
	
	for_each = local.app_server_root_volume_tags
	key = each.key
	value = each.value
}