# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



locals {
	origin_id = "s3"
}



resource aws_cloudfront_distribution main {
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
		domain_name = aws_s3_bucket.data.bucket_regional_domain_name
		origin_path = "/static"
		origin_access_control_id = aws_cloudfront_origin_access_control.main.id
	}
	
	origin {
		origin_id = "${local.origin_id}-media"
		domain_name = aws_s3_bucket.data.bucket_regional_domain_name
		origin_path = "/media"
		origin_access_control_id = aws_cloudfront_origin_access_control.main.id
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
		cache_policy_id = data.aws_cloudfront_cache_policy.main.id
		viewer_protocol_policy = "https-only"
		compress = true
	}
	
	ordered_cache_behavior {
		path_pattern = "favicon.ico"
		target_origin_id = local.origin_id
		allowed_methods = [ "GET", "HEAD" ]
		cached_methods = [ "GET", "HEAD" ]
		cache_policy_id = data.aws_cloudfront_cache_policy.main.id
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
		bucket = aws_s3_bucket.logs.bucket_domain_name
		prefix = "cloudfront/"
	}
	
	tags = {
		Name: "${local.project_name} Distribuition"
	}
}


resource aws_cloudfront_origin_access_control main {
	name = local.project_prefix
	description = "${local.project_name} Origin Access Control"
	origin_access_control_origin_type = "s3"
	signing_behavior = "always"
	signing_protocol = "sigv4"
}


data aws_cloudfront_cache_policy main {
	name = "Managed-CachingOptimized"
}


resource aws_cloudfront_function favicon_redirect {
	name = "${local.project_prefix}-faviconRedirect"
	code = file( "favicon_redirect.js" )
	runtime = "cloudfront-js-1.0"
}