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
	iam_fleet_role = "arn:aws:iam::983585628015:role/aws-ec2-spot-fleet-tagging-role"	# TODO
	
	launch_template_config {
		launch_template_specification {
			id = aws_launch_template.main.id
			version = aws_launch_template.main.latest_version
		}
	}
	
	tags = {
		Name = "${var.name} Spot Fleet Request"
	}
}


resource aws_launch_template main {
	name = local.module_prefix
	update_default_version = true
	
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
		subnet_id = var.subnet_id
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
	source = "gitlab.com/marcelotsvaz/user-data/external"
	version = "~> 1.0.1"
	
	input_dir = "../../../${var.identifier}/scripts"
	output_dir = "../../../deployment/${local.module_prefix}"
	
	files = [ "perInstance.sh" ]
	
	environment = merge( var.environment, {
		instanceName = var.name
		hostname = var.hostname
		user = var.hostname
	} )
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
	zone_id = var.private_hosted_zone.zone_id
	
	name = "${var.hostname}.${var.private_hosted_zone.name}"
	type = "A"
	ttl = "60"
	records = [ data.aws_instance.main.private_ip ]
}