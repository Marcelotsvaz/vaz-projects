#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Main bucket.
#-------------------------------------------------------------------------------
resource "aws_s3_bucket" "bucket" {
	bucket = lower( "${local.projectCode}-${var.environment}" )
	
	versioning {
		enabled = true
	}
	
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				sse_algorithm = "AES256"
			}
		}
	}
	
	logging {
		target_bucket = aws_s3_bucket.logs_bucket.id
		target_prefix = "s3/"
	}
	
	cors_rule {
		allowed_methods = [ "GET" ]
		allowed_origins = [ "https://staging.vazprojects.com" ]
	}
	
	tags = {
		Name: "${local.projectName} Bucket"
	}
}


resource "aws_s3_bucket_public_access_block" "bucket" {
	bucket = aws_s3_bucket.bucket.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "bucket_policy" {
	bucket = aws_s3_bucket.bucket.id
	policy = data.aws_iam_policy_document.bucket_policy.json
}


data "aws_iam_policy_document" "bucket_policy" {
	statement {
		sid = "cloudfrontAccess"
		
		principals {
			type = "AWS"
			# TODO: Cloudfront.
			identifiers = [ "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E1LOKSB1MRE35F" ]
		}
		
		actions = [ "s3:GetObject" ]
		
		resources = [
			# TODO: remove staging.
			"${aws_s3_bucket.bucket.arn}/staging/static/*",
			"${aws_s3_bucket.bucket.arn}/staging/media/*",
		]
	}
}



# 
# Logs bucket.
#-------------------------------------------------------------------------------
resource "aws_s3_bucket" "logs_bucket" {
	bucket = lower( "${local.projectCode}-${var.environment}-logs" )
	
	acl = "log-delivery-write"
	
	server_side_encryption_configuration {
		rule {
			apply_server_side_encryption_by_default {
				sse_algorithm = "AES256"
			}
		}
	}
	
	tags = {
		Name: "${local.projectName} Logs Bucket"
	}
}


resource "aws_s3_bucket_public_access_block" "logs_bucket" {
	bucket = aws_s3_bucket.logs_bucket.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}