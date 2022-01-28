#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource "aws_acm_certificate" "cloudfront" {
	provider = aws.us_east_1
	
	domain_name = local.domain
	validation_method = "DNS"
	
	tags = {
		Name: "${local.project_name} CloudFront Certificate"
	}
	
	lifecycle {
		create_before_destroy = true
	}
}


resource "aws_acm_certificate_validation" "cloudfront" {
	provider = aws.us_east_1
	
	certificate_arn = aws_acm_certificate.cloudfront.arn
	validation_record_fqdns = [ for record in aws_route53_record.acm : record.fqdn ]
}