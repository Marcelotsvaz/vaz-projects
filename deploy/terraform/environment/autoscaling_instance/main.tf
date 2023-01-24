# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Instances
#-------------------------------------------------------------------------------
resource aws_autoscaling_group main {
	name = local.autoscaling_group_name
	vpc_zone_identifier = var.subnet_ids
	min_size = 1
	max_size = 10
	default_cooldown = 120
	instance_refresh { strategy = "Rolling" }
	capacity_rebalance = true
	
	launch_template {
		id = aws_launch_template.main.id
		version = aws_launch_template.main.latest_version
	}
	
	depends_on = [
		aws_cloudwatch_event_rule.main,
		aws_lambda_permission.main,
	]
	
	dynamic tag {
		for_each = merge( { Name = "${var.name} Auto Scaling Group" }, var.default_tags )
		
		content {
			key = tag.key
			value = tag.value
			propagate_at_launch = false
		}
	}
}


resource aws_autoscaling_policy main {
	name = "CPU Tracking Policy"
	autoscaling_group_name = aws_autoscaling_group.main.name
	estimated_instance_warmup = 60
	policy_type = "TargetTrackingScaling"
	
	target_tracking_configuration {
		target_value = "80"
		predefined_metric_specification { predefined_metric_type = "ASGAverageCPUUtilization" }
	}
}


resource aws_launch_template main {
	name = "${var.prefix}-${var.identifier}-launchTemplate"
	update_default_version = true
	
	instance_market_options { market_type = "spot" }
	image_id = var.ami_id
	instance_type = var.instance_type
	iam_instance_profile { arn = aws_iam_instance_profile.main.arn }
	user_data = module.user_data.content_base64
	ebs_optimized = true
	
	block_device_mappings {
		device_name = "/dev/xvda"
		
		ebs {
			volume_size = var.root_volume_size
			encrypted = true
		}
	}
	
	network_interfaces {
		ipv6_address_count = var.ipv6_address_count
		security_groups = var.vpc_security_group_ids
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


module user_data {
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



# 
# Private DNS
#-------------------------------------------------------------------------------
resource aws_route53_record a {
	zone_id = var.private_hosted_zone.zone_id
	
	name = "${var.hostname}.${var.private_hosted_zone.name}"
	type = "A"
	ttl = "10"
	records = [ "0.0.0.0" ]
	
	lifecycle {
		ignore_changes = [ records ]	# This record is managed by a Lambda function.
	}
}