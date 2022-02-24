# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Load balancer server.
#-------------------------------------------------------------------------------
module "load_balancer" {
	source = "./instance"
	
	name = "${local.project_name} Load Balancer"
	instance_type = "t3a.nano"
	
	subnet_id = aws_subnet.subnet_c.id
	ipv6_address_count = 1
	vpc_security_group_ids = [
		aws_default_security_group.common.id,
		aws_security_group.public.id,
	]
	private_hosted_zone = aws_route53_zone.private
	hostname = "load-balancer"
	
	role_name = "${local.project_code}-${var.environment}-loadBalancer"
	role_policy = data.aws_iam_policy_document.load_balancer_policy
	
	root_volume_size = 5
	user_data_base64 = module.load_balancer_user_data.content_base64
	default_tags = local.default_tags
}


resource "aws_eip" "load_balancer_ip" {
	instance = module.load_balancer.id
	
	tags = {
		Name = "${local.project_name} Load Balancer Elastic IP"
	}
}


module "load_balancer_user_data" {
	source = "./user_data"
	
	input_dir = "../../../loadBalancer/scripts"
	output_dir = "../../../deployment/loadBalancer"
	
	files = [ "perInstance.sh" ]
	
	templates = { "environment.env.tpl": "environment.env" }
	
	context = {
		hostname = "load-balancer"
		repository_snapshot = var.repository_snapshot
		bucket = aws_s3_bucket.bucket.id
		region = local.region
		domain = local.domain
		static_files_domain = local.static_files_domain
		monitoring_domain = local.monitoring_domain
		private_domain = local.private_domain
		hosted_zone_id = data.aws_route53_zone.hosted_zone.zone_id
		cloudfront_certificate_arn = data.aws_acm_certificate.cloudfront.arn
	}
}


data "aws_iam_policy_document" "load_balancer_policy" {
	statement {
		sid = "s3ListBucket"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.bucket.arn ]
	}
	
	statement {
		sid = "s3WriteDeployment"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:DeleteObject",
		]
		
		resources = [ "${aws_s3_bucket.bucket.arn}/deployment/*" ]
	}
	
	statement {
		sid = "route53ChangeRecordSets"
		
		actions = [
			"route53:ChangeResourceRecordSets",
			"route53:GetChange",
		]
		
		resources = [
			data.aws_route53_zone.hosted_zone.arn,
			"arn:aws:route53:::change/*",
		]
	}
	
	statement {
		sid = "acmImportCertificate"
		
		actions = [ "acm:ImportCertificate" ]
		
		resources = [ data.aws_acm_certificate.cloudfront.arn ]
	}
}



# 
# Application server.
#-------------------------------------------------------------------------------
module "app_server" {
	source = "./instance"
	
	name = "${local.project_name} Application Server"
	instance_type = "t3a.small"
	
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [
		aws_default_security_group.common.id,
		aws_security_group.private.id,
	]
	private_hosted_zone = aws_route53_zone.private
	hostname = "application"
	
	role_name = "${local.project_code}-${var.environment}-appServer"
	role_policy = data.aws_iam_policy_document.app_server_policy
	
	root_volume_size = 5
	user_data_base64 = module.app_server_user_data.content_base64
	default_tags = local.default_tags
}


module "app_server_user_data" {
	source = "./user_data"
	
	input_dir = "../../../application/scripts"
	output_dir = "../../../deployment/application"
	
	files = [ "perInstance.sh" ]
	
	templates = { "environment.env.tpl": "environment.env" }
	
	context = {
		hostname = "application"
		region = local.region
		repository_snapshot = var.repository_snapshot
		application_image = var.application_image
		environment = var.environment
		domain = local.domain
		static_files_domain = local.static_files_domain
		bucket = aws_s3_bucket.bucket.id
	}
}


data "aws_iam_policy_document" "app_server_policy" {
	statement {
		sid = "s3ListBucket"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.bucket.arn ]
	}
	
	statement {
		sid = "s3GetDeployment"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
		]
		
		resources = [ "${aws_s3_bucket.bucket.arn}/deployment/*" ]
	}
	
	statement {
		sid = "s3WriteMedia"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:DeleteObject",
		]
		
		resources = [ "${aws_s3_bucket.bucket.arn}/media/*" ]
	}
}



# 
# Database server.
#-------------------------------------------------------------------------------
module "database_server" {
	source = "./instance"
	
	name = "${local.project_name} Database Server"
	instance_type = "t3a.nano"
	
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [
		aws_default_security_group.common.id,
		aws_security_group.private.id,
	]
	private_hosted_zone = aws_route53_zone.private
	hostname = "postgres"
	
	role_name = "${local.project_code}-${var.environment}-databaseServer"
	role_policy = data.aws_iam_policy_document.database_server_policy
	
	root_volume_size = 5
	user_data_base64 = module.database_server_user_data.content_base64
	default_tags = local.default_tags
}


resource "aws_ebs_volume" "database_volume" {
	availability_zone = aws_subnet.subnet_c.availability_zone
	size = 1
	type = "gp3"
	encrypted = true
	
	tags = {
		Name: "${local.project_name} Database Data Volume"
	}
}


resource "aws_volume_attachment" "database_volume_attachment" {
	volume_id = aws_ebs_volume.database_volume.id
	instance_id = module.database_server.id
	device_name = "/dev/xvdg"
	stop_instance_before_detaching = true
}


module "database_server_user_data" {
	source = "./user_data"
	
	input_dir = "../../../database/scripts"
	output_dir = "../../../deployment/database"
	
	files = [ "perInstance.sh" ]
	
	templates = { "environment.env.tpl": "environment.env" }
	
	context = {
		hostname = "postgres"
		data_volume_id = aws_ebs_volume.database_volume.id
		repository_snapshot = var.repository_snapshot
		bucket = aws_s3_bucket.bucket.id
		region = local.region
	}
}


data "aws_iam_policy_document" "database_server_policy" {
	statement {
		sid = "s3ListBucket"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.bucket.arn ]
	}
	
	statement {
		sid = "s3GetDeployment"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
		]
		
		resources = [ "${aws_s3_bucket.bucket.arn}/deployment/*" ]
	}
	
	statement {
		sid = "ec2DescribeVolume"
		
		actions = [ "ec2:DescribeVolumes" ]
		
		resources = [ "*" ]
	}
}



# 
# Monitoring server.
#-------------------------------------------------------------------------------
module "monitoring_server" {
	source = "./instance"
	
	name = "${local.project_name} Monitoring Server"
	instance_type = "t3a.nano"
	
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [
		aws_default_security_group.common.id,
		aws_security_group.private.id,
	]
	private_hosted_zone = aws_route53_zone.private
	hostname = "monitoring"
	
	role_name = "${local.project_code}-${var.environment}-monitoringServer"
	role_policy = data.aws_iam_policy_document.monitoring_server_policy
	
	root_volume_size = 5
	user_data_base64 = module.monitoring_server_user_data.content_base64
	default_tags = local.default_tags
}


resource "aws_ebs_volume" "monitoring_volume" {
	availability_zone = aws_subnet.subnet_c.availability_zone
	size = 5
	type = "gp3"
	encrypted = true
	
	tags = {
		Name: "${local.project_name} Monitoring Data Volume"
	}
}


resource "aws_volume_attachment" "monitoring_volume_attachment" {
	volume_id = aws_ebs_volume.monitoring_volume.id
	instance_id = module.monitoring_server.id
	device_name = "/dev/xvdg"
	stop_instance_before_detaching = true
}


module "monitoring_server_user_data" {
	source = "./user_data"
	
	input_dir = "../../../monitoring/scripts"
	output_dir = "../../../deployment/monitoring"
	
	files = [ "perInstance.sh" ]
	
	templates = { "environment.env.tpl": "environment.env" }
	
	context = {
		hostname = "monitoring"
		data_volume_id = aws_ebs_volume.monitoring_volume.id
		repository_snapshot = var.repository_snapshot
		bucket = aws_s3_bucket.bucket.id
		region = local.region
		monitoring_domain = local.monitoring_domain
	}
}


data "aws_iam_policy_document" "monitoring_server_policy" {
	statement {
		sid = "s3ListBucket"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.bucket.arn ]
	}
	
	statement {
		sid = "s3GetDeployment"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
		]
		
		resources = [ "${aws_s3_bucket.bucket.arn}/deployment/*" ]
	}
	
	statement {
		sid = "ec2DescribeVolume"
		
		actions = [ "ec2:DescribeVolumes" ]
		
		resources = [ "*" ]
	}
}