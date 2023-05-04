# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Data Bucket
#-------------------------------------------------------------------------------
resource aws_s3_bucket data {
	# Create a bucket for staging environments but use a persistent one for production.
	count = var.environment == "staging" ? 1 : 0
	
	bucket = lower( local.project_prefix )
	force_destroy = var.environment == "staging"	# Just to be safe.
	
	tags = {
		Name: "${local.project_name} Bucket"
	}
}


data aws_s3_bucket data {
	bucket = lower( local.project_prefix )
	
	depends_on = [ aws_s3_bucket.data ]
}


resource aws_s3_bucket_server_side_encryption_configuration data {
	bucket = data.aws_s3_bucket.data.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource aws_s3_bucket_versioning data {
	bucket = data.aws_s3_bucket.data.id
	
	versioning_configuration {
		status = "Enabled"
	}
}


resource aws_s3_bucket_public_access_block data {
	bucket = data.aws_s3_bucket.data.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}


resource aws_s3_bucket_policy data {
	bucket = data.aws_s3_bucket.data.id
	policy = data.aws_iam_policy_document.data_bucket.json
}


data aws_iam_policy_document data_bucket {
	statement {
		sid = "cloudfrontAccess"
		actions = [ "s3:GetObject" ]
		resources = [
			"${data.aws_s3_bucket.data.arn}/static/*",
			"${data.aws_s3_bucket.data.arn}/media/*",
		]
		condition {
			variable = "AWS:SourceArn"
			test = "StringEquals"
			values = [ aws_cloudfront_distribution.main.arn ]
		}
		principals {
			type = "Service"
			identifiers = [ "cloudfront.amazonaws.com" ]
		}
	}
}


resource aws_s3_bucket_cors_configuration data {
	bucket = data.aws_s3_bucket.data.id
	
	cors_rule {
		allowed_methods = [ "GET" ]
		allowed_origins = [ "https://${local.domain}" ]
	}
}


resource aws_s3_bucket_logging data {
	bucket = data.aws_s3_bucket.data.id
	
	target_bucket = data.aws_s3_bucket.logs.id
	target_prefix = "s3/"
}



# 
# Logs Bucket
#-------------------------------------------------------------------------------
resource aws_s3_bucket logs {
	# Create bucket for staging environments but use a persistent one for production.
	count = var.environment == "staging" ? 1 : 0
	
	bucket = lower( "${local.project_prefix}-logs" )
	force_destroy = var.environment == "staging"	# Just to be safe.
	
	tags = {
		Name: "${local.project_name} Logs Bucket"
	}
}


data aws_s3_bucket logs {
	bucket = lower( "${local.project_prefix}-logs" )
	
	depends_on = [ aws_s3_bucket.logs ]
}


resource aws_s3_bucket_server_side_encryption_configuration logs {
	bucket = data.aws_s3_bucket.logs.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}


resource aws_s3_bucket_public_access_block logs {
	bucket = data.aws_s3_bucket.logs.id
	
	block_public_acls = true
	ignore_public_acls = true
	block_public_policy = true
	restrict_public_buckets = true
}


resource aws_s3_bucket_acl logs {
	bucket = data.aws_s3_bucket.logs.id
	
	acl = "log-delivery-write"
}