#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Private Route53 hosted zone.
#-------------------------------------------------------------------------------
resource "aws_route53_zone" "private" {
	name = "private.${local.domain}"
	
	vpc { vpc_id = aws_vpc.vpc.id }
	
	tags = {
		Name: "${local.project_name} Private Hosted Zone"
	}
}


# resource "aws_route53_record" "private_soa" {
# 	zone_id = aws_route53_zone.private.zone_id
# 	allow_overwrite = true
	
# 	name = aws_route53_zone.private.name
# 	type = "SOA"
# 	ttl = "3600"
# 	records = [ "${aws_route53_zone.private.name_servers[0]} awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400" ]
# }


# resource "aws_route53_record" "private_ns" {
# 	zone_id = aws_route53_zone.private.zone_id
# 	allow_overwrite = true
	
# 	name = aws_route53_zone.private.name
# 	type = "NS"
# 	ttl = "3600"
# 	records = aws_route53_zone.private.name_servers
# }



# 
# External Route53 hosted zone.
#-------------------------------------------------------------------------------
data "aws_route53_zone" "hosted_zone" {
	name = local.domain
}



# 
# Load balancer.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "a_load_balancer" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = local.domain
	type = "A"
	ttl = "60"
	records = [ aws_eip.load_balancer_ip.public_ip ]
}


resource "aws_route53_record" "aaaa_load_balancer" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = local.domain
	type = "AAAA"
	ttl = "60"
	records = [ module.load_balancer.ipv6_address ]
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
# Monitoring server.
#-------------------------------------------------------------------------------
resource "aws_route53_record" "a_monitoring_server" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = "monitoring.${local.domain}"
	type = "A"
	ttl = "60"
	records = [ aws_eip.monitoring_server_ip.public_ip ]
}


resource "aws_route53_record" "aaaa_monitoring_server" {
	zone_id = data.aws_route53_zone.hosted_zone.zone_id
	
	name = "monitoring.${local.domain}"
	type = "AAAA"
	ttl = "60"
	records = [ module.monitoring_server.ipv6_address ]
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