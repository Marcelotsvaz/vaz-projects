# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Instances.
#-------------------------------------------------------------------------------
resource "aws_autoscaling_group" "autoscaling_group" {
	name = "${var.name} Auto Scaling Group"
	
	vpc_zone_identifier = var.subnet_ids
	
	min_size = 2
	max_size = 10
	
	launch_template { id = aws_launch_template.launch_template.id }
	
	tag {
		key = "Name"
		value = "${var.name} Auto Scaling Group"
		propagate_at_launch = false
	}
	
	tag {
		key = "TestTag"
		value = "Test Tag Propagation"
		propagate_at_launch = false
	}
	
	# dynamic tag {
	# 	var.default_tags
		
	# 	key = "Name"
	# 	value = "${var.name} Auto Scaling Group"
	# 	propagate_at_launch = false
	# }
}


resource "aws_launch_template" "launch_template" {
	update_default_version = true
	
	image_id = data.aws_ami.arch_linux.id
	instance_type = var.instance_type
	instance_market_options { market_type = "spot" }
	vpc_security_group_ids = var.vpc_security_group_ids
	iam_instance_profile { arn = aws_iam_instance_profile.instance_profile.arn }
	user_data = var.user_data_base64
	ebs_optimized = true
	
	block_device_mappings {
		device_name = "/dev/xvda"
		
		ebs {
			volume_size = var.root_volume_size
			encrypted = true
		}
	}
	
	tags = {
		Name = "${var.name} Launch Template"
	}
	
	tag_specifications {
		resource_type = "instance"
		
		tags = {
			Name = var.name
		}
	}
}


# resource "aws_spot_instance_request" "instance" {
# 	root_block_device {
# 		tags = local.instance_root_volume_tags
# 	}
	
# 	tags = {
# 		Name = "${var.name} Spot Request"
# 	}
# }


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
# locals {
# 	instance_root_volume_tags = merge( { Name = "${var.name} Root Volume" }, var.default_tags )
# }


# resource "aws_ec2_tag" "instance_tags" {
# 	resource_id = aws_spot_instance_request.instance.spot_instance_id
	
# 	for_each = merge( { Name = var.name }, var.default_tags )
# 	key = each.key
# 	value = each.value
# }


# resource "aws_ec2_tag" "instance_root_volume_tags" {
# 	resource_id = aws_spot_instance_request.instance.root_block_device.0.volume_id
	
# 	for_each = local.instance_root_volume_tags
# 	key = each.key
# 	value = each.value
# }



# 
# Private DNS.
#-------------------------------------------------------------------------------
# resource "aws_route53_record" "a" {
# 	zone_id = var.private_hosted_zone.zone_id
	
# 	name = "${var.hostname}.${var.private_hosted_zone.name}"
# 	type = "A"
# 	ttl = "60"
# 	records = [ aws_spot_instance_request.instance.private_ip ]
# }