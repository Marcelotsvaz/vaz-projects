# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Instances.
#-------------------------------------------------------------------------------
resource "aws_spot_instance_request" "instance" {
	ami = data.aws_ami.arch_linux.id
	instance_type = var.instance_type
	subnet_id = var.subnet_id
	ipv6_address_count = var.ipv6_address_count
	vpc_security_group_ids = var.vpc_security_group_ids
	iam_instance_profile = aws_iam_instance_profile.instance_profile.name
	user_data_base64 = module.user_data.content_base64
	ebs_optimized = true
	instance_interruption_behavior = "stop"
	wait_for_fulfillment = true
	
	root_block_device {
		volume_size = var.root_volume_size
		encrypted = true
		
		tags = local.instance_root_volume_tags
	}
	
	tags = {
		Name = "${var.name} Spot Request"
	}
}


module "user_data" {
	source = "../user_data"
	
	input_dir = "../../../${var.identifier}/scripts"
	output_dir = "../../../deployment/${var.prefix}/${var.identifier}"
	
	files = [ "perInstance.sh" ]
	
	environment = merge( var.environment, {
		instanceName = var.name
		hostname = var.hostname
		user = var.hostname
	} )
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
# Instance tags.
#-------------------------------------------------------------------------------
locals {
	instance_root_volume_tags = merge( { Name = "${var.name} Root Volume" }, var.default_tags )
}


resource "aws_ec2_tag" "instance_tags" {
	resource_id = aws_spot_instance_request.instance.spot_instance_id
	
	for_each = merge( { Name = var.name }, var.default_tags )
	key = each.key
	value = each.value
}


resource "aws_ec2_tag" "instance_root_volume_tags" {
	resource_id = aws_spot_instance_request.instance.root_block_device.0.volume_id
	
	for_each = local.instance_root_volume_tags
	key = each.key
	value = each.value
}



# 
# Private DNS.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "a" {
	zone_id = var.private_hosted_zone.zone_id
	
	name = "${var.hostname}.${var.private_hosted_zone.name}"
	type = "A"
	ttl = "60"
	records = [ aws_spot_instance_request.instance.private_ip ]
}