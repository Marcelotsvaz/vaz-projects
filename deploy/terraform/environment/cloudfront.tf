# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



locals {
	origin_id = "s3"
}



resource "aws_cloudfront_distribution" "distribution" {
	comment = "${local.project_name} Distribuition"
	aliases = [ local.static_files_domain ]
	enabled = true
	is_ipv6_enabled = true
	
	viewer_certificate {
		acm_certificate_arn = data.aws_acm_certificate.cloudfront.arn
		ssl_support_method = "sni-only"
		minimum_protocol_version = "TLSv1.2_2021"
	}
	
	origin {
		origin_id = "${local.origin_id}-static"
		domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
		origin_path = "/static"
		
		s3_origin_config { origin_access_identity = aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path }
	}
	
	origin {
		origin_id = "${local.origin_id}-media"
		domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
		origin_path = "/media"
		
		s3_origin_config { origin_access_identity = aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path }
	}
	
	origin_group {
		origin_id = local.origin_id
		
		member { origin_id = "${local.origin_id}-static" }
		
		member { origin_id = "${local.origin_id}-media" }
		
		failover_criteria {
			status_codes = [ 403 ]
		}
	}
	
	default_cache_behavior {
		target_origin_id = local.origin_id
		allowed_methods = [ "GET", "HEAD" ]
		cached_methods = [ "GET", "HEAD" ]
		cache_policy_id = data.aws_cloudfront_cache_policy.cache_policy.id
		viewer_protocol_policy = "https-only"
		compress = true
	}
	
	ordered_cache_behavior {
		path_pattern = "favicon.ico"
		target_origin_id = local.origin_id
		allowed_methods = [ "GET", "HEAD" ]
		cached_methods = [ "GET", "HEAD" ]
		cache_policy_id = data.aws_cloudfront_cache_policy.cache_policy.id
		viewer_protocol_policy = "https-only"
		compress = true
		
		function_association {
			event_type = "viewer-request"
			function_arn = aws_cloudfront_function.favicon_redirect.arn
		}
	}
	
	restrictions {
		geo_restriction { restriction_type = "none" }
	}
	
	logging_config {
		bucket = aws_s3_bucket.logs_bucket.bucket_domain_name
		prefix = "cloudfront/"
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


resource "aws_cloudfront_function" "favicon_redirect" {
	name = "${local.project_code}-${var.environment}-faviconRedirect"
	code = file( "favicon_redirect.js" )
	runtime = "cloudfront-js-1.0"
}