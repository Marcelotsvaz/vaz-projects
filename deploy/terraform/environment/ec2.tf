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


data aws_iam_policy_document common {
	statement {
		sid = "perInstanceListBucket"
		actions = [ "s3:ListBucket" ]
		resources = [ data.aws_s3_bucket.data.arn ]
	}
	
	statement {
		sid = "perInstanceGetDeployment"
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
		]
		resources = [ "${data.aws_s3_bucket.data.arn}/deployment/*" ]
	}
}



# 
# Load Balancer Server
#-------------------------------------------------------------------------------
module load_balancer {
	source = "../modules/instance"
	
	# Name.
	prefix = local.project_prefix
	identifier = "loadBalancer"
	name = "${local.project_name} Load Balancer"
	hostname = "load-balancer"
	user = "load-balancer"
	
	# Configuration.
	ami_id = data.aws_ami.main.id
	min_vcpu_count = 2
	min_memory_gib = 0.5
	
	# Network.
	subnet_ids = module.vpc.subnets[*].id
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
		bucket = data.aws_s3_bucket.data.id
		AWS_DEFAULT_REGION = local.region
		domain = local.domain
		staticFilesUrl = "https://${local.static_files_domain}/"
		monitoringDomain = local.monitoring_domain
		hostedZoneId = data.aws_route53_zone.public.zone_id
		cloudfrontCertificateArn = aws_acm_certificate.cloudfront.arn
	}
}


resource aws_eip load_balancer {
	instance = module.load_balancer.id
	
	tags = {
		Name = "${local.project_name} Load Balancer Elastic IP"
	}
}


data aws_iam_policy_document load_balancer {
	source_policy_documents = [ data.aws_iam_policy_document.common.json ]
	
	statement {
		sid = "dehydratedDnsChallenge"
		actions = [
			"route53:ChangeResourceRecordSets",
			"route53:GetChange",
		]
		resources = [
			data.aws_route53_zone.public.arn,
			"arn:aws:route53:::change/*",
		]
	}
	
	statement {
		sid = "dehydratedUploadCertificate"
		actions = [
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:DeleteObject",
		]
		resources = [ "${data.aws_s3_bucket.data.arn}/deployment/tls/*" ]
	}
	
	statement {
		sid = "dehydratedUpdateCertificate"
		actions = [ "acm:ImportCertificate" ]
		resources = [ aws_acm_certificate.cloudfront.arn ]
	}
}



# 
# Application Server
#-------------------------------------------------------------------------------
module app_server {
	source = "../modules/autoscaling_group"
	
	# Name.
	prefix = local.project_prefix
	identifier = "application"
	name = "${local.project_name} Application Server"
	hostname = "application"
	user = "application"
	
	# Configuration.
	ami_id = data.aws_ami.main.id
	min_vcpu_count = 2
	min_memory_gib = 2
	
	# Network.
	subnet_ids = module.vpc.subnets[*].id
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
		staticFilesUrl = "https://${local.static_files_domain}/"
		s3Endpoint = replace(
			data.aws_s3_bucket.data.bucket_regional_domain_name,
			"${data.aws_s3_bucket.data.bucket}.",
			"https://",
		)
		bucket = data.aws_s3_bucket.data.id
	}
}


data aws_iam_policy_document app_server {
	source_policy_documents = [ data.aws_iam_policy_document.common.json ]
	
	statement {
		sid = "djangoS3StorageBackend"
		actions = [
			"s3:GetObject",
			"s3:GetObjectAcl",
			"s3:PutObject",
			"s3:PutObjectAcl",
			"s3:DeleteObject",
		]
		resources = [ "${data.aws_s3_bucket.data.arn}/media/*" ]
	}
}



# 
# Database Server
#-------------------------------------------------------------------------------
module database_server {
	source = "../modules/instance"
	
	# Name.
	prefix = local.project_prefix
	identifier = "database"
	name = "${local.project_name} Database Server"
	hostname = "postgres"
	user = "postgres"
	
	# Configuration.
	ami_id = data.aws_ami.main.id
	min_vcpu_count = 2
	min_memory_gib = 0.5
	
	# Network.
	subnet_ids = [ module.vpc.subnets[2].id ]	# TODO: Fix this with volumes.
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
		bucket = data.aws_s3_bucket.data.id
		AWS_DEFAULT_REGION = local.region
	}
}


resource aws_ebs_volume database {
	availability_zone = module.vpc.subnets[2].availability_zone
	size = 1
	type = "gp3"
	encrypted = true
	
	tags = {
		Name = "${local.project_name} Database Data Volume"
	}
}


# Wait for the volume to be detached since we use skip_destroy on the aws_volume_attachment.
# Otherwise we need to stop the instance before detaching which is not supported by
# aws_spot_fleet_request.
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
	source_policy_documents = [ data.aws_iam_policy_document.common.json ]
}



# 
# Monitoring Server
#-------------------------------------------------------------------------------
module monitoring_server {
	source = "../modules/instance"
	
	# Name.
	prefix = local.project_prefix
	identifier = "monitoring"
	name = "${local.project_name} Monitoring Server"
	hostname = "monitoring"
	user = "monitoring"
	
	# Configuration.
	ami_id = data.aws_ami.main.id
	min_vcpu_count = 2
	min_memory_gib = 1
	
	# Network.
	subnet_ids = [ module.vpc.subnets[2].id ]	# TODO: Fix this with volumes.
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
		bucket = data.aws_s3_bucket.data.id
		AWS_DEFAULT_REGION = local.region
		monitoringDomain = local.monitoring_domain
		environment = var.environment
	}
}


resource aws_ebs_volume monitoring {
	availability_zone = module.vpc.subnets[2].availability_zone
	size = 5
	type = "gp3"
	encrypted = true
	
	tags = {
		Name = "${local.project_name} Monitoring Data Volume"
	}
}


# Wait for the volume to be detached since we use skip_destroy on the aws_volume_attachment.
# Otherwise we need to stop the instance before detaching which is not supported by
# aws_spot_fleet_request.
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
	source_policy_documents = [ data.aws_iam_policy_document.common.json ]
	
	statement {
		sid = "prometheusEc2ServiceDiscovery"
		actions = [
			"ec2:DescribeInstances",
			"ec2:DescribeAvailabilityZones",
		]
		resources = [ "*" ]
	}
}