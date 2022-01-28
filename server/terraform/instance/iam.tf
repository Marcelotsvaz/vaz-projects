#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "aws_iam_policy_document" "instance_assume_role_policy" {
	statement {
		sid = "ec2AssumeRole"
		
		principals {
			type = "Service"
			identifiers = [ "ec2.amazonaws.com" ]
		}
		
		actions = [ "sts:AssumeRole" ]
	}
}


data "aws_iam_policy_document" "instance_policy" {
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
			# TODO: remove staging, add nginx.
			"${aws_s3_bucket.bucket.arn}/staging/*",
			"${aws_s3_bucket.logs_bucket.arn}/staging/*",
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


resource "aws_iam_role" "instance_role" {
	name = "${local.projectCode}-${var.environment}-role"
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