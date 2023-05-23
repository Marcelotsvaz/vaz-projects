# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Base Domain
#-------------------------------------------------------------------------------
resource aws_route53domains_registered_domain main {
	domain_name = local.domain
	
	dynamic name_server {
		for_each = aws_route53_zone.production.name_servers
		
		content {
			name = name_server.value
		}
	}
	
	tags = {
		Name = "${local.project_name} Domain"
	}
}


resource aws_route53_zone production {
	name = local.domain
	
	tags = {
		Name = "${local.project_name} Hosted Zone"
	}
}


resource aws_route53_record production_soa {
	zone_id = aws_route53_zone.production.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.production.name
	type = "SOA"
	ttl = "3600"
	records = [
		"${aws_route53_zone.production.primary_name_server} awsdns-hostmaster.amazon.com 1 ${2 * 3600} ${0.25 * 3600} ${14 * 24 * 3600} ${24 * 3600}"
	]
}


resource aws_route53_record production_ns {
	zone_id = aws_route53_zone.production.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.production.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.production.name_servers
}


# Delegates staging sub-domain to it's own zone.
resource aws_route53_record production_staging_ns {
	zone_id = aws_route53_zone.production.zone_id
	
	name = aws_route53_zone.staging.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.staging.name_servers
}


# Delegates portfolio sub-domain to it's own zone.
resource aws_route53_record production_portfolio_ns {
	zone_id = aws_route53_zone.production.zone_id
	
	name = aws_route53_zone.portfolio.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.portfolio.name_servers
}



# 
# Staging Domain
#-------------------------------------------------------------------------------
resource aws_route53_zone staging {
	name = "staging.${aws_route53_zone.production.name}"
	
	tags = {
		Name = "${local.project_name} Hosted Zone"
	}
}


resource aws_route53_record staging_soa {
	zone_id = aws_route53_zone.staging.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.staging.name
	type = "SOA"
	ttl = "3600"
	records = [
		"${aws_route53_zone.staging.primary_name_server} awsdns-hostmaster.amazon.com 1 ${2 * 3600} ${0.25 * 3600} ${14 * 24 * 3600} ${24 * 3600}"
	]
}


resource aws_route53_record staging_ns {
	zone_id = aws_route53_zone.staging.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.staging.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.staging.name_servers
}



# 
# Portfolio Domain
#-------------------------------------------------------------------------------
resource aws_route53_zone portfolio {
	name = "portfolio.${aws_route53_zone.production.name}"
	
	tags = {
		Name = "Portfolio Hosted Zone"
		Project = "Portfolio"
	}
}


resource aws_route53_record portfolio_soa {
	zone_id = aws_route53_zone.portfolio.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.portfolio.name
	type = "SOA"
	ttl = "3600"
	records = [
		"${aws_route53_zone.portfolio.primary_name_server} awsdns-hostmaster.amazon.com 1 ${2 * 3600} ${0.25 * 3600} ${14 * 24 * 3600} ${24 * 3600}"
	]
}


resource aws_route53_record portfolio_ns {
	zone_id = aws_route53_zone.portfolio.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.portfolio.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_zone.portfolio.name_servers
}