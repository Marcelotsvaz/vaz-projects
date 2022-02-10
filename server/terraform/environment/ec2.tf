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
	instance_type = "t3a.micro"
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [ aws_default_security_group.security_group.id ]
	iam_instance_profile = aws_iam_instance_profile.instance_profile.name
	root_volume_size = 5
	default_tags = local.default_tags
}



# 
# Application server.
#-------------------------------------------------------------------------------
module "app_server" {
	source = "./instance"
	
	name = "Application Server"
	instance_type = "t3a.small"
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [ aws_default_security_group.security_group.id ]
	iam_instance_profile = aws_iam_instance_profile.instance_profile.name
	root_volume_size = 5
	user_data_base64 = module.app_server_user_data.content_base64
	default_tags = local.default_tags
}


module "app_server_user_data" {
	source = "./user_data"
	
	input_dir = "../../scripts"
	output_dir = "../../../deployment"
	
	files = [
		"perInstance.sh",
		"perBoot.sh",
		"perShutdown.sh",
	]
	
	templates = { "environment.env.tpl": "environment.env" }
	
	context = {
		environment = var.environment
		repository_snapshot = var.repository_snapshot
		application_image = var.application_image
		region = local.region
		domain = local.domain
		hosted_zone_id = data.aws_route53_zone.hosted_zone.zone_id
		bucket = aws_s3_bucket.bucket.id
		cloudfront_id = aws_cloudfront_distribution.distribution.id
		cloudfront_certificate_arn = aws_acm_certificate.cloudfront.arn
	}
}