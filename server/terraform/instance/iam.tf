#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "aws_iam_policy_document" "instance_assume_role_policy" {
	statement {
		actions = [ "sts:AssumeRole" ]
		
		principals {
			type = "Service"
			identifiers = [ "ec2.amazonaws.com" ]
		}
	}
}


data "aws_iam_policy_document" "instance_policy" {
	statement {
		sid = "s3ListBuckets"
		
		actions = [ "s3:ListBucket" ]
		
		resources = [
			"arn:aws:s3:::vaz-projects",
			"arn:aws:s3:::vaz-projects-logs",
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
			"arn:aws:s3:::vaz-projects/staging/*",
			"arn:aws:s3:::vaz-projects-logs/staging/*",
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
		
		resources = [ "arn:aws:acm:us-east-1:983585628015:certificate/5fb0c8c9-790c-4bf2-8916-363f4be21463" ]
	}
}


resource "aws_iam_role" "instance_role" {
	name = "${local.projectCode}${title(var.environment)}Role"
	assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
	
	inline_policy {
		name = "rolePolicy"
		
		policy = data.aws_iam_policy_document.instance_policy.json
	}
	
	tags = {
		Name: "${local.projectName} Role"
	}
}


resource "aws_iam_instance_profile" "instance_profile" {
	name = "${local.projectCode}${title(var.environment)}InstanceProfile"
	role = aws_iam_role.instance_role.name
	
	tags = {
		Name: "${local.projectName} Instance Profile"
	}
}