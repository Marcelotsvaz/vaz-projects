#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Cloudfront.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "a_cloudfront" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = "static-files.${data.aws_route53_zone.hosted_zone.name}"
	type = "A"
	
	alias {
		name = aws_cloudfront_distribution.distribution.domain_name
		zone_id = aws_cloudfront_distribution.distribution.hosted_zone_id
		evaluate_target_health = false
	}
}


resource "aws_route53_record" "aaaa_cloudfront" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = "static-files.${data.aws_route53_zone.hosted_zone.name}"
	type = "AAAA"
	
	alias {
		name = aws_cloudfront_distribution.distribution.domain_name
		zone_id = aws_cloudfront_distribution.distribution.hosted_zone_id
		evaluate_target_health = false
	}
}



# 
# Third-party records.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "caa" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = data.aws_route53_zone.hosted_zone.name
	type = "CAA"
	ttl = "3600"
	records = [ "0 issue \"letsencrypt.org\"" ]
}


resource "aws_route53_record" "txt_google" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = data.aws_route53_zone.hosted_zone.name
	type = "TXT"
	ttl = "3600"
	records = [ "google-site-verification=x9tLElJp9QijYSWjI5x5LwQh5Am0r1xfHhF7iYeHSPs" ]
}