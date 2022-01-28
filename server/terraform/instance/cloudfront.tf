#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource "aws_cloudfront_distribution" "distribution" {
	comment = "${local.project_name} Distribuition"
	aliases = [ "static-files.${local.domain}" ]
	enabled = true
	is_ipv6_enabled = true
	
	viewer_certificate {
		acm_certificate_arn = aws_acm_certificate.cloudfront.arn
		ssl_support_method = "sni-only"
		minimum_protocol_version = "TLSv1.2_2021"
	}
	
	origin {
		origin_id = "S3-Staging-Static"
		domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
		origin_path = "/staging/static"
		
		s3_origin_config { origin_access_identity = aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path }
	}
	
	origin {
		origin_id = "S3-Staging-Media"
		domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
		origin_path = "/staging/media"
		
		s3_origin_config { origin_access_identity = aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path }
	}
	
	origin_group {
		origin_id = "S3-Staging"
		
		member { origin_id = "S3-Staging-Static" }
		
		member { origin_id = "S3-Staging-Media" }
		
		failover_criteria {
			status_codes = [ 403 ]
		}
	}
	
	default_cache_behavior {
		target_origin_id = "S3-Staging"
		allowed_methods = [ "GET", "HEAD" ]
		cached_methods = [ "GET", "HEAD" ]
		cache_policy_id = data.aws_cloudfront_cache_policy.cache_policy.id
		viewer_protocol_policy = "https-only"
		compress = true
	}
	
	ordered_cache_behavior {
		path_pattern = "favicon.ico"
		target_origin_id = "S3-Staging-Static"
		allowed_methods = [ "GET", "HEAD" ]
		cached_methods = [ "GET", "HEAD" ]
		cache_policy_id = data.aws_cloudfront_cache_policy.cache_policy.id
		viewer_protocol_policy = "https-only"
		compress = true
		
		lambda_function_association {
			event_type = "origin-request"
			lambda_arn = "arn:aws:lambda:us-east-1:983585628015:function:FaviconRedirect:3"
		}
	}
	
	restrictions {
		geo_restriction { restriction_type = "none" }
	}
	
	logging_config {
		bucket = aws_s3_bucket.logs_bucket.bucket_domain_name
		prefix = "staging/cloudfront/"
	}
	
	tags = {
		Name: "${local.project_name} Distribuition"
	}
}


resource "aws_cloudfront_origin_access_identity" "identity" {
	comment = "${local.project_name} Origin Access Identity"
}


data "aws_cloudfront_cache_policy" "cache_policy" {
	name = "Managed-CachingOptimized"
}