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
	
	name = "Load Balancer"
	instance_type = "t3a.nano"
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [ aws_default_security_group.security_group.id ]
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
		domain = local.domain
		repository_snapshot = var.repository_snapshot
		bucket = aws_s3_bucket.bucket.id
		region = local.region
		hosted_zone_id = data.aws_route53_zone.hosted_zone.zone_id
	}
}


data "aws_iam_policy_document" "load_balancer_policy" {
	statement {
		sid = "s3ListBuckets"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [
			aws_s3_bucket.bucket.arn,
			aws_s3_bucket.logs_bucket.arn,
		]
	}
	
	statement {
		sid = "s3WriteToBucket"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:DeleteObject",
		]
		
		resources = [
			"${aws_s3_bucket.bucket.arn}/*",
			"${aws_s3_bucket.logs_bucket.arn}/*",
		]
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
}



# 
# Application server.
#-------------------------------------------------------------------------------
module "app_server" {
	source = "./instance"
	
	name = "Application Server"
	instance_type = "t3a.small"
	subnet_id = aws_subnet.subnet_c.id
	private_ip = "10.0.3.150"	# TODO: Remove this.
	vpc_security_group_ids = [ aws_default_security_group.security_group.id ]
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
		region = local.region
		repository_snapshot = var.repository_snapshot
		application_image = var.application_image
		environment = var.environment
		domain = local.domain
		bucket = aws_s3_bucket.bucket.id
	}
}


data "aws_iam_policy_document" "app_server_policy" {
	statement {
		sid = "s3ListBuckets"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [
			aws_s3_bucket.bucket.arn,
			aws_s3_bucket.logs_bucket.arn,
		]
	}
	
	statement {
		sid = "s3WriteToBucket"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:DeleteObject",
		]
		
		resources = [
			"${aws_s3_bucket.bucket.arn}/*",
			"${aws_s3_bucket.logs_bucket.arn}/*",
		]
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
		
		resources = [ aws_acm_certificate.cloudfront.arn ]
	}
}



# 
# Database server.
#-------------------------------------------------------------------------------
module "database_server" {
	source = "./instance"
	
	name = "Database Server"
	instance_type = "t3a.nano"
	subnet_id = aws_subnet.subnet_c.id
	private_ip = "10.0.3.200"	# TODO: Remove this.
	vpc_security_group_ids = [ aws_default_security_group.security_group.id ]
	role_name = "${local.project_code}-${var.environment}-databaseServer"
	role_policy = data.aws_iam_policy_document.database_server_policy
	root_volume_size = 5
	user_data_base64 = module.database_server_user_data.content_base64
	default_tags = local.default_tags
}


module "database_server_user_data" {
	source = "./user_data"
	
	input_dir = "../../../database/scripts"
	output_dir = "../../../deployment/database"
	
	files = [ "perInstance.sh" ]
	
	templates = { "environment.env.tpl": "environment.env" }
	
	context = {
		domain = local.domain
		repository_snapshot = var.repository_snapshot
		bucket = aws_s3_bucket.bucket.id
		region = local.region
	}
}


data "aws_iam_policy_document" "database_server_policy" {
	statement {
		sid = "s3ListBuckets"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.bucket.arn ]
	}
	
	statement {
		sid = "s3ReadFromBucket"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
		]
		
		resources = [ "${aws_s3_bucket.bucket.arn}/*" ]
	}
}