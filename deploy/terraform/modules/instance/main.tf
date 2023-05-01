# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Instance
#-------------------------------------------------------------------------------
resource aws_spot_fleet_request main {
	target_capacity = 1
	instance_interruption_behaviour = "stop"
	terminate_instances_on_delete = true
	wait_for_fulfillment = true
	allocation_strategy = "priceCapacityOptimized"
	spot_price = 0.025
	iam_fleet_role = aws_iam_role.fleet.arn
	
	launch_template_config {
		launch_template_specification {
			id = aws_launch_template.main.id
			version = aws_launch_template.main.latest_version
		}
		
		overrides {
			subnet_id = join( ", ", var.subnet_ids )
		}
	}
	
	lifecycle {
		replace_triggered_by = [ null_resource.deployment ]
	}
	
	tags = {
		Name = "${var.name} Spot Fleet Request"
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


data aws_instance main {
	instance_tags = { "aws:ec2spot:fleet-request-id" = aws_spot_fleet_request.main.id }
	
	filter {
		name = "instance-state-name"
		values = [ "running" ]
	}
}



# 
# Private DNS
#-------------------------------------------------------------------------------
resource aws_route53_record a {
	count = var.private_hosted_zone == null ? 0 : 1
	
	zone_id = var.private_hosted_zone.zone_id
	
	name = "${var.hostname}.${var.private_hosted_zone.name}"
	type = "A"
	ttl = "60"
	records = [ data.aws_instance.main.private_ip ]
}