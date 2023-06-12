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
	min_size = var.highly_available ? 2 : 1
	max_size = 10
	default_cooldown = 120
	instance_refresh { strategy = "Rolling" }
	capacity_rebalance = true
	
	mixed_instances_policy {
		instances_distribution {
			on_demand_percentage_above_base_capacity = 0	# Use only Spot Instances.
			spot_allocation_strategy = "price-capacity-optimized"
			spot_max_price = 0.025
		}
		
		launch_template {
			launch_template_specification {
				launch_template_id = aws_launch_template.main.id
				version = aws_launch_template.main.latest_version
			}
		}
	}
	
	depends_on = [
		aws_cloudwatch_event_rule.main,
		aws_lambda_permission.main,
	]
	
	dynamic tag {
		for_each = merge( { Name = "${var.name} Auto Scaling Group" }, data.aws_default_tags.main.tags )
		
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


data aws_ec2_instance_types main {
	filter {
		name = "supported-boot-mode"
		values = [ "uefi" ]
	}
	
	filter {
		name = "supported-usage-class"
		values = [ "spot" ]
	}
}


resource aws_launch_template main {
	name = local.module_prefix
	update_default_version = true
	
	image_id = var.ami_id
	vpc_security_group_ids = var.vpc_security_group_ids
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
	
	instance_requirements {
		vcpu_count { min = var.min_vcpu_count }
		memory_mib { min = var.min_memory_gib * 1024 }
		burstable_performance = "included"
		allowed_instance_types = data.aws_ec2_instance_types.main.instance_types
	}
	
	tag_specifications {
		resource_type = "spot-instances-request"
		tags = merge( { Name = "${var.name} Spot Request" }, data.aws_default_tags.main.tags )
	}
	
	tag_specifications {
		resource_type = "instance"
		tags = merge( { Name = var.name }, data.aws_default_tags.main.tags )
	}
	
	tag_specifications {
		resource_type = "volume"
		tags = merge( { Name = "${var.name} Root Volume" }, data.aws_default_tags.main.tags )
	}
	
	tags = {
		Name = "${var.name} Launch Template"
	}
}


module user_data {
	source = "gitlab.com/marcelotsvaz/user-data/external"
	version = "~> 1.0.1"
	
	input_dir = "../../../${var.identifier}/scripts/"
	output_dir = "../../../deployment/terraform/${local.module_prefix}/"
	
	files = var.files
	templates = var.templates
	
	context = var.context
	environment = merge( var.environment, {
		instanceName = var.name
		hostname = var.hostname
		user = var.user
	} )
}


resource null_resource deployment {
	triggers = var.instance_replacement_triggers
}


data aws_default_tags main {}



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