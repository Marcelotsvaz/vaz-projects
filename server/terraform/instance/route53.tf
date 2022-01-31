#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# External Route53 hosted zone.
#-------------------------------------------------------------------------------
data "aws_route53_zone" "hosted_zone" {
	name = local.domain
}



# 
# CloudFront.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "a_cloudfront" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = "static-files.${local.domain}"
	type = "A"
	
	alias {
		name = aws_cloudfront_distribution.distribution.domain_name
		zone_id = aws_cloudfront_distribution.distribution.hosted_zone_id
		evaluate_target_health = false
	}
}


resource "aws_route53_record" "aaaa_cloudfront" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = "static-files.${local.domain}"
	type = "AAAA"
	
	alias {
		name = aws_cloudfront_distribution.distribution.domain_name
		zone_id = aws_cloudfront_distribution.distribution.hosted_zone_id
		evaluate_target_health = false
	}
}



# 
# ACM certificate validation.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "acm" {
	for_each = { for record in aws_acm_certificate.cloudfront.domain_validation_options : record.domain_name => record }
	
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = each.value.resource_record_name
	type = each.value.resource_record_type
	ttl = "60"
	records = [ each.value.resource_record_value ]
}



# 
# Third-party records.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "caa" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = local.domain
	type = "CAA"
	ttl = "3600"
	records = [
		"0 issue \"letsencrypt.org\"",
		"0 issue \"amazonaws.com\"",
	]
}


resource "aws_route53_record" "txt_google" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = local.domain
	type = "TXT"
	ttl = "3600"
	records = [ "google-site-verification=x9tLElJp9QijYSWjI5x5LwQh5Am0r1xfHhF7iYeHSPs" ]
}