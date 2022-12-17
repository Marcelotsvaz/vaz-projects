# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# vazprojects.com hosted zone.
#-------------------------------------------------------------------------------
resource "aws_route53_zone" "production" {
	name = local.domain
	
	provisioner "local-exec" {
		command = <<-EOF
			aws route53domains update-domain-nameservers	\
				--region us-east-1							\
				--domain-name ${local.domain}				\
				--nameservers ${join( " ", [ for ns in aws_route53_zone.production.name_servers : "Name=${ns}"] )}
		EOF
	}
	
	tags = {
		Name: "${local.project_name} Hosted Zone"
	}
}


resource "aws_route53_record" "production_soa" {
	zone_id = aws_route53_zone.production.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.production.name
	type = "SOA"
	ttl = "3600"
	records = [ "${aws_route53_zone.production.primary_name_server} awsdns-hostmaster.amazon.com 1 ${2 * 3600} ${0.25 * 3600} ${14 * 24 * 3600} ${24 * 3600}" ]
}


resource "aws_route53_record" "production_ns" {
	zone_id = aws_route53_zone.production.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.production.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.production.name_servers
}


resource "aws_route53_record" "production_staging_ns" {
	zone_id = aws_route53_zone.production.zone_id
	
	name = aws_route53_zone.staging.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.staging.name_servers
}


resource "aws_route53_record" "production_portfolio_ns" {
	zone_id = aws_route53_zone.production.zone_id
	
	name = aws_route53_zone.portfolio.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.portfolio.name_servers
}



# 
# staging.vazprojects.com hosted zone.
#-------------------------------------------------------------------------------
resource "aws_route53_zone" "staging" {
	name = "staging.${aws_route53_zone.production.name}"
	
	tags = {
		Name: "${local.project_name} Hosted Zone"
	}
}


resource "aws_route53_record" "staging_soa" {
	zone_id = aws_route53_zone.staging.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.staging.name
	type = "SOA"
	ttl = "3600"
	records = [ "${aws_route53_zone.staging.primary_name_server} awsdns-hostmaster.amazon.com 1 ${2 * 3600} ${0.25 * 3600} ${14 * 24 * 3600} ${24 * 3600}" ]
}


resource "aws_route53_record" "staging_ns" {
	zone_id = aws_route53_zone.staging.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.staging.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.staging.name_servers
}



# 
# portfolio.vazprojects.com hosted zone.
#-------------------------------------------------------------------------------
resource "aws_route53_zone" "portfolio" {
	name = "portfolio.${aws_route53_zone.production.name}"
	
	tags = {
		Name: "Portfolio Hosted Zone"
		Project: "Portfolio"
	}
}


resource "aws_route53_record" "portfolio_soa" {
	zone_id = aws_route53_zone.portfolio.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.portfolio.name
	type = "SOA"
	ttl = "3600"
	records = [ "${aws_route53_zone.portfolio.primary_name_server} awsdns-hostmaster.amazon.com 1 ${2 * 3600} ${0.25 * 3600} ${14 * 24 * 3600} ${24 * 3600}" ]
}


resource "aws_route53_record" "portfolio_ns" {
	zone_id = aws_route53_zone.portfolio.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.portfolio.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.portfolio.name_servers
}