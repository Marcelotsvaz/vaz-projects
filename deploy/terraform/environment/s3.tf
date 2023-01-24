# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Main bucket.
#-------------------------------------------------------------------------------
resource aws_s3_bucket bucket {
	bucket = lower( "${local.project_code}-${var.environment}" )
	force_destroy = var.environment != "production"	# force_destroy only on staging environment.
	
	tags = {
		Name: "${local.project_name} Bucket"
	}
}


resource aws_s3_bucket_server_side_encryption_configuration bucket {
	bucket = aws_s3_bucket.bucket.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource aws_s3_bucket_versioning bucket {
	bucket = aws_s3_bucket.bucket.id
	
	versioning_configuration {
		status = "Enabled"
	}
}


resource aws_s3_bucket_public_access_block bucket {
	bucket = aws_s3_bucket.bucket.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}


resource aws_s3_bucket_policy bucket_policy {
	bucket = aws_s3_bucket.bucket.id
	policy = data.aws_iam_policy_document.bucket_policy.json
}


data aws_iam_policy_document bucket_policy {
	# Used by CloudFront.
	statement {
		sid = "cloudfrontAccess"
		
		principals {
			type = "Service"
			identifiers = [ "cloudfront.amazonaws.com" ]
		}
		
		actions = [ "s3:GetObject" ]
		
		resources = [
			"${aws_s3_bucket.bucket.arn}/static/*",
			"${aws_s3_bucket.bucket.arn}/media/*",
		]
		
		condition {
			variable = "AWS:SourceArn"
			test = "StringEquals"
			values = [ aws_cloudfront_distribution.distribution.arn ]
		}
	}
}


resource aws_s3_bucket_cors_configuration bucket {
	bucket = aws_s3_bucket.bucket.id
	
	cors_rule {
		allowed_methods = [ "GET" ]
		allowed_origins = [ "https://${local.domain}" ]
	}
}


resource aws_s3_bucket_logging bucket {
	bucket = aws_s3_bucket.bucket.id
	
	target_bucket = aws_s3_bucket.logs_bucket.id
	target_prefix = "s3/"
}



# 
# Logs bucket.
#-------------------------------------------------------------------------------
resource aws_s3_bucket logs_bucket {
	bucket = lower( "${local.project_code}-${var.environment}-logs" )
	force_destroy = var.environment != "production"	# force_destroy only on staging environment.
	
	tags = {
		Name: "${local.project_name} Logs Bucket"
	}
}


resource aws_s3_bucket_server_side_encryption_configuration logs_bucket {
	bucket = aws_s3_bucket.logs_bucket.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource aws_s3_bucket_public_access_block logs_bucket {
	bucket = aws_s3_bucket.logs_bucket.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}


resource aws_s3_bucket_acl logs_bucket {
	bucket = aws_s3_bucket.logs_bucket.id
	
	acl = "log-delivery-write"
}