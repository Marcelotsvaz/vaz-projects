# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Instance.
#-------------------------------------------------------------------------------
resource "aws_ec2_fleet" "fleet" {
	target_capacity_specification {
		default_target_capacity_type = "spot"
		total_target_capacity = 1
	}
	
	spot_options { instance_interruption_behavior = "stop" }
	terminate_instances = true
	
	launch_template_config {
		launch_template_specification {
			launch_template_id = aws_launch_template.launch_template.id
			version = aws_launch_template.launch_template.latest_version
		}
	}
	
	lifecycle {
		replace_triggered_by = [ aws_launch_template.launch_template ]	# Force instance replacement.
	}
	
	tags = {
		Name = "${var.name} Fleet"
	}
}


resource "aws_launch_template" "launch_template" {
	name = "${var.prefix}-${var.identifier}-launchTemplate"
	update_default_version = true
	
	image_id = var.ami_id
	instance_type = var.instance_type
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


data "aws_instance" "instance" {
	instance_tags = { "aws:ec2:fleet-id" = aws_ec2_fleet.fleet.id }
}



# 
# Private DNS.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "a" {
	zone_id = var.private_hosted_zone.zone_id
	
	name = "${var.hostname}.${var.private_hosted_zone.name}"
	type = "A"
	ttl = "60"
	records = [ data.aws_instance.instance.private_ip ]
}