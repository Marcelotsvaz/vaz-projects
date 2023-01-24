# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Common
#-------------------------------------------------------------------------------
data aws_ami main {
	most_recent = true
	owners = [ "self" ]
	
	filter {
		name = "name"
		values = [ "VAZ Projects AMI" ]
	}
}



# 
# Load Balancer Server
#-------------------------------------------------------------------------------
module load_balancer {
	source = "./instance"
	
	# Name.
	name = "${local.project_name} Load Balancer"
	identifier = "loadBalancer"
	hostname = "load-balancer"
	prefix = "${local.project_code}-${var.environment}"
	
	# Configuration.
	ami_id = data.aws_ami.main.id
	instance_type = "t3a.nano"
	root_volume_size = 5
	
	# Network.
	subnet_id = aws_subnet.subnet_c.id
	ipv6_address_count = 1
	vpc_security_group_ids = [
		aws_default_security_group.common.id,
		aws_security_group.public.id,
	]
	private_hosted_zone = aws_route53_zone.private
	
	# Environment.
	role_policy = data.aws_iam_policy_document.load_balancer
	environment = {
		sshKey = local.ssh_key
		repositorySnapshot = var.repository_snapshot
		bucket = aws_s3_bucket.data.id
		AWS_DEFAULT_REGION = local.region
		domain = local.domain
		staticFilesDomain = local.static_files_domain
		monitoringDomain = local.monitoring_domain
		privateDomain = local.private_domain
		hostedZoneId = data.aws_route53_zone.public.zone_id
		cloudfrontCertificateArn = data.aws_acm_certificate.cloudfront.arn
	}
	
	# Tags.
	default_tags = local.default_tags
}


resource aws_eip load_balancer {
	instance = module.load_balancer.id
	
	tags = {
		Name = "${local.project_name} Load Balancer Elastic IP"
	}
}


data aws_iam_policy_document load_balancer {
	# Used in perInstance.sh.
	statement {
		sid = "s3ListBucket"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.data.arn ]
	}
	
	# Used in perInstance.sh.
	# Used by dehydrated.
	statement {
		sid = "s3WriteDeployment"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:DeleteObject",
		]
		
		resources = [ "${aws_s3_bucket.data.arn}/deployment/*" ]
	}
	
	# Used by dehydrated.
	statement {
		sid = "route53ChangeRecordSets"
		
		actions = [
			"route53:ChangeResourceRecordSets",
			"route53:GetChange",
		]
		
		resources = [
			data.aws_route53_zone.public.arn,
			"arn:aws:route53:::change/*",
		]
	}
	
	# Used by dehydrated.
	statement {
		sid = "acmImportCertificate"
		
		actions = [ "acm:ImportCertificate" ]
		
		resources = [ data.aws_acm_certificate.cloudfront.arn ]
	}
}



# 
# Application Server
#-------------------------------------------------------------------------------
module app_server {
	source = "./autoscaling_instance"
	
	# Name.
	name = "${local.project_name} Application Server"
	identifier = "application"
	hostname = "application"
	prefix = "${local.project_code}-${var.environment}"
	
	# Configuration.
	ami_id = data.aws_ami.main.id
	instance_type = "t3a.small"
	root_volume_size = 5
	
	# Network.
	subnet_ids = [ aws_subnet.subnet_c.id ]
	vpc_security_group_ids = [
		aws_default_security_group.common.id,
		aws_security_group.private.id,
	]
	private_hosted_zone = aws_route53_zone.private
	
	# Environment.
	role_policy = data.aws_iam_policy_document.app_server
	environment = {
		sshKey = local.ssh_key
		repositorySnapshot = var.repository_snapshot
		AWS_DEFAULT_REGION = local.region
		applicationImage = var.application_image
		DJANGO_SETTINGS_MODULE = "settings.${var.environment}"
		domain = local.domain
		staticFilesDomain = local.static_files_domain
		s3Endpoint = replace( aws_s3_bucket.data.bucket_regional_domain_name, "${aws_s3_bucket.data.bucket}.", "https://" )
		bucket = aws_s3_bucket.data.id
	}
	
	# Tags.
	default_tags = local.default_tags
}


data aws_iam_policy_document app_server {
	# Used in perInstance.sh.
	statement {
		sid = "s3ListBucket"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.data.arn ]
	}
	
	# Used in perInstance.sh.
	statement {
		sid = "s3GetDeployment"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
		]
		
		resources = [ "${aws_s3_bucket.data.arn}/deployment/*" ]
	}
	
	# Used by Django S3 storage backend.
	statement {
		sid = "s3WriteMedia"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:DeleteObject",
		]
		
		resources = [ "${aws_s3_bucket.data.arn}/media/*" ]
	}
}



# 
# Database Server
#-------------------------------------------------------------------------------
module database_server {
	source = "./instance"
	
	# Name.
	name = "${local.project_name} Database Server"
	identifier = "database"
	hostname = "postgres"
	prefix = "${local.project_code}-${var.environment}"
	
	# Configuration.
	ami_id = data.aws_ami.main.id
	instance_type = "t3a.nano"
	root_volume_size = 5
	
	# Network.
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [
		aws_default_security_group.common.id,
		aws_security_group.private.id,
	]
	private_hosted_zone = aws_route53_zone.private
	
	# Environment.
	role_policy = data.aws_iam_policy_document.database_server
	environment = {
		sshKey = local.ssh_key
		dataVolumeId = aws_ebs_volume.database.id
		repositorySnapshot = var.repository_snapshot
		bucket = aws_s3_bucket.data.id
		AWS_DEFAULT_REGION = local.region
	}
	
	# Tags.
	default_tags = local.default_tags
}


resource aws_ebs_volume database {
	availability_zone = aws_subnet.subnet_c.availability_zone
	size = 1
	type = "gp3"
	encrypted = true
	
	tags = {
		Name: "${local.project_name} Database Data Volume"
	}
}


# Wait for the volume to be detached since we use skip_destroy on the aws_volume_attachment. Otherwise we need to stop
# the instance before detaching which is not supported by aws_spot_fleet_request.
resource null_resource wait_database_volume {
	triggers = { instance_id = module.database_server.id }
	
	provisioner local-exec {
		environment = { AWS_DEFAULT_REGION = local.region }
		command = "aws ec2 wait volume-available --volume-ids ${aws_ebs_volume.database.id}"
	}
}


resource aws_volume_attachment database {
	volume_id = aws_ebs_volume.database.id
	instance_id = module.database_server.id
	device_name = "/dev/xvdg"
	skip_destroy = true
	
	depends_on = [ null_resource.wait_database_volume ]
}


data aws_iam_policy_document database_server {
	# Used in perInstance.sh.
	statement {
		sid = "s3ListBucket"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.data.arn ]
	}
	
	# Used in perInstance.sh.
	statement {
		sid = "s3GetDeployment"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
		]
		
		resources = [ "${aws_s3_bucket.data.arn}/deployment/*" ]
	}
}



# 
# Monitoring Server
#-------------------------------------------------------------------------------
module monitoring_server {
	source = "./instance"
	
	# Name.
	name = "${local.project_name} Monitoring Server"
	identifier = "monitoring"
	hostname = "monitoring"
	prefix = "${local.project_code}-${var.environment}"
	
	# Configuration.
	ami_id = data.aws_ami.main.id
	instance_type = "t3a.micro"
	root_volume_size = 5
	
	# Network.
	subnet_id = aws_subnet.subnet_c.id
	vpc_security_group_ids = [
		aws_default_security_group.common.id,
		aws_security_group.private.id,
	]
	private_hosted_zone = aws_route53_zone.private
	
	# Environment.
	role_policy = data.aws_iam_policy_document.monitoring_server
	environment = {
		sshKey = local.ssh_key
		dataVolumeId = aws_ebs_volume.monitoring.id
		repositorySnapshot = var.repository_snapshot
		bucket = aws_s3_bucket.data.id
		AWS_DEFAULT_REGION = local.region
		monitoringDomain = local.monitoring_domain
		environment = var.environment
	}
	
	# Tags.
	default_tags = local.default_tags
}


resource aws_ebs_volume monitoring {
	availability_zone = aws_subnet.subnet_c.availability_zone
	size = 5
	type = "gp3"
	encrypted = true
	
	tags = {
		Name: "${local.project_name} Monitoring Data Volume"
	}
}


# Wait for the volume to be detached since we use skip_destroy on the aws_volume_attachment. Otherwise we need to stop
# the instance before detaching which is not supported by aws_spot_fleet_request.
resource null_resource wait_monitoring_volume {
	triggers = { instance_id = module.monitoring_server.id }
	
	provisioner local-exec {
		environment = { AWS_DEFAULT_REGION = local.region }
		command = "aws ec2 wait volume-available --volume-ids ${aws_ebs_volume.monitoring.id}"
	}
}


resource aws_volume_attachment monitoring {
	volume_id = aws_ebs_volume.monitoring.id
	instance_id = module.monitoring_server.id
	device_name = "/dev/xvdg"
	skip_destroy = true
	
	depends_on = [ null_resource.wait_monitoring_volume ]
}


data aws_iam_policy_document monitoring_server {
	# Used in perInstance.sh.
	statement {
		sid = "s3ListBucket"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [ aws_s3_bucket.data.arn ]
	}
	
	# Used in perInstance.sh.
	statement {
		sid = "s3GetDeployment"
		
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
		]
		
		resources = [ "${aws_s3_bucket.data.arn}/deployment/*" ]
	}
	
	# Used by Prometheus EC2 service discovery.
	statement {
		sid = "ec2DescribeInstances"
		
		actions = [
			"ec2:DescribeInstances",
			"ec2:DescribeAvailabilityZones",
		]
		
		resources = [ "*" ]
	}
}