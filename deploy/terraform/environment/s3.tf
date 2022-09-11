# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Main bucket.
#-------------------------------------------------------------------------------
resource "aws_s3_bucket" "bucket" {
	bucket = lower( "${local.project_code}-${var.environment}" )
	
	tags = {
		Name: "${local.project_name} Bucket"
	}
}


resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
	bucket = aws_s3_bucket.bucket.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource "aws_s3_bucket_versioning" "bucket" {
	bucket = aws_s3_bucket.bucket.id
	
	versioning_configuration {
		status = "Enabled"
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
	# Used by CloudFront.
	statement {
		sid = "cloudfrontAccess"
		
		principals {
			type = "AWS"
			identifiers = [ aws_cloudfront_origin_access_identity.identity.iam_arn ]
		}
		
		actions = [ "s3:GetObject" ]
		
		resources = [
			"${aws_s3_bucket.bucket.arn}/static/*",
			"${aws_s3_bucket.bucket.arn}/media/*",
		]
	}
}


resource "aws_s3_bucket_cors_configuration" "bucket" {
	bucket = aws_s3_bucket.bucket.id
	
	cors_rule {
		allowed_methods = [ "GET" ]
		allowed_origins = [ "https://${local.domain}" ]
	}
}


resource "aws_s3_bucket_logging" "bucket" {
	bucket = aws_s3_bucket.bucket.id
	
	target_bucket = aws_s3_bucket.logs_bucket.id
	target_prefix = "s3/"
}



# 
# Logs bucket.
#-------------------------------------------------------------------------------
resource "aws_s3_bucket" "logs_bucket" {
	bucket = lower( "${local.project_code}-${var.environment}-logs" )
	
	tags = {
		Name: "${local.project_name} Logs Bucket"
	}
}


resource "aws_s3_bucket_server_side_encryption_configuration" "logs_bucket" {
	bucket = aws_s3_bucket.logs_bucket.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource "aws_s3_bucket_public_access_block" "logs_bucket" {
	bucket = aws_s3_bucket.logs_bucket.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}


resource "aws_s3_bucket_acl" "logs_bucket" {
	bucket = aws_s3_bucket.logs_bucket.id
	
	acl = "log-delivery-write"
}