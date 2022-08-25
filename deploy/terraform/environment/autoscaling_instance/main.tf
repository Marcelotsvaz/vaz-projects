# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Instances.
#-------------------------------------------------------------------------------
resource "aws_autoscaling_group" "autoscaling_group" {
	name = local.autoscaling_group_name
	vpc_zone_identifier = var.subnet_ids
	min_size = 1
	max_size = 10
	default_cooldown = 120
	instance_refresh { strategy = "Rolling" }
	capacity_rebalance = true
	
	launch_template {
		id = aws_launch_template.launch_template.id
		version = aws_launch_template.launch_template.latest_version
	}
	
	depends_on = [
		aws_cloudwatch_event_rule.autoscaling_event_rule,
		aws_lambda_permission.autoscaling_lambda_resource_policy,
	]
	
	dynamic "tag" {
		for_each = merge( { Name = "${var.name} Auto Scaling Group" }, var.default_tags )
		
		content {
			key = tag.key
			value = tag.value
			propagate_at_launch = false
		}
	}
}


resource "aws_autoscaling_policy" "scale_down" {
	name = "CPU Tracking Policy"
	autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
	estimated_instance_warmup = 60
	policy_type = "TargetTrackingScaling"
	
	target_tracking_configuration {
		target_value = "80"
		predefined_metric_specification { predefined_metric_type = "ASGAverageCPUUtilization" }
	}
}


resource "aws_launch_template" "launch_template" {
	name = "${var.prefix}-${var.identifier}-launchTemplate"
	update_default_version = true
	
	image_id = data.aws_ami.arch_linux.id
	instance_type = var.instance_type
	instance_market_options { market_type = "spot" }
	vpc_security_group_ids = var.vpc_security_group_ids
	iam_instance_profile { arn = aws_iam_instance_profile.instance_profile.arn }
	user_data = module.user_data.content_base64
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
# Private DNS.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "a" {
	zone_id = var.private_hosted_zone.zone_id
	
	name = "${var.hostname}.${var.private_hosted_zone.name}"
	type = "A"
	ttl = "10"
	records = [ "0.0.0.0" ]
	
	lifecycle {
		ignore_changes = [ records ]	# This record is managed by a Lambda function.
	}
}