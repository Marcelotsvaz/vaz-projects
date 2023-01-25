# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Data Bucket
#-------------------------------------------------------------------------------
resource aws_s3_bucket data {
	bucket = lower( local.project_prefix )
	force_destroy = var.environment != "production"	# force_destroy only on staging environment.
	
	tags = {
		Name: "${local.project_name} Bucket"
	}
}


resource aws_s3_bucket_server_side_encryption_configuration data {
	bucket = aws_s3_bucket.data.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource aws_s3_bucket_versioning data {
	bucket = aws_s3_bucket.data.id
	
	versioning_configuration {
		status = "Enabled"
	}
}


resource aws_s3_bucket_public_access_block data {
	bucket = aws_s3_bucket.data.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}


resource aws_s3_bucket_policy data {
	bucket = aws_s3_bucket.data.id
	policy = data.aws_iam_policy_document.data_bucket.json
}


data aws_iam_policy_document data_bucket {
	# Used by CloudFront.
	statement {
		sid = "cloudfrontAccess"
		
		principals {
			type = "Service"
			identifiers = [ "cloudfront.amazonaws.com" ]
		}
		
		actions = [ "s3:GetObject" ]
		
		resources = [
			"${aws_s3_bucket.data.arn}/static/*",
			"${aws_s3_bucket.data.arn}/media/*",
		]
		
		condition {
			variable = "AWS:SourceArn"
			test = "StringEquals"
			values = [ aws_cloudfront_distribution.main.arn ]
		}
	}
}


resource aws_s3_bucket_cors_configuration data {
	bucket = aws_s3_bucket.data.id
	
	cors_rule {
		allowed_methods = [ "GET" ]
		allowed_origins = [ "https://${local.domain}" ]
	}
}


resource aws_s3_bucket_logging data {
	bucket = aws_s3_bucket.data.id
	
	target_bucket = aws_s3_bucket.logs.id
	target_prefix = "s3/"
}



# 
# Logs Bucket
#-------------------------------------------------------------------------------
resource aws_s3_bucket logs {
	bucket = lower( "${local.project_prefix}-logs" )
	force_destroy = var.environment != "production"	# force_destroy only on staging environment.
	
	tags = {
		Name: "${local.project_name} Logs Bucket"
	}
}


resource aws_s3_bucket_server_side_encryption_configuration logs {
	bucket = aws_s3_bucket.logs.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource aws_s3_bucket_public_access_block logs {
	bucket = aws_s3_bucket.logs.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}


resource aws_s3_bucket_acl logs {
	bucket = aws_s3_bucket.logs.id
	
	acl = "log-delivery-write"
}