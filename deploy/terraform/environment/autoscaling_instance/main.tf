# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Instances.
#-------------------------------------------------------------------------------
resource "aws_autoscaling_group" "autoscaling_group" {
	name = "${var.unique_identifier}-autoScalingGroup"
	launch_template { id = aws_launch_template.launch_template.id }
	vpc_zone_identifier = var.subnet_ids
	min_size = 2
	max_size = 10
	
	dynamic "tag" {
		for_each = merge( { Name = "${var.name} Auto Scaling Group" }, var.default_tags )
		
		content {
			key = tag.key
			value = tag.value
			propagate_at_launch = false
		}
	}
}


resource "aws_launch_template" "launch_template" {
	name = "${var.unique_identifier}-launchTemplate"
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
	
	tag_specifications {
		resource_type = "spot-instances-request"
		tags = merge( { Name = "${var.name} Spot Request" }, var.default_tags )
	}
	
	tag_specifications {
		resource_type = "instance"
		tags = merge( { Name = var.name }, var.default_tags )
	}
	
	tag_specifications {
		resource_type = "volume"
		tags = merge( { Name = "${var.name} Root Volume" }, var.default_tags )
	}
	
	tags = {
		Name = "${var.name} Launch Template"
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
# Private DNS.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "a" {
	zone_id = var.private_hosted_zone.zone_id
	
	name = "${var.hostname}.${var.private_hosted_zone.name}"
	type = "A"
	ttl = "10"
	records = []
}