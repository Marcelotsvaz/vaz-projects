#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# vazprojects.com hosted zone.
#-------------------------------------------------------------------------------
resource "aws_route53_delegation_set" "production" {
	
}


resource "aws_route53_zone" "production" {
	name = "vazprojects.com"
	delegation_set_id = aws_route53_delegation_set.production.id
	
	provisioner "local-exec" {
		command = <<-EOF
			aws route53domains update-domain-nameservers	\
				--region us-east-1							\
				--domain-name vazprojects.com				\
				--nameservers ${join( " ", [ for ns in aws_route53_delegation_set.production.name_servers : "Name=${ns}"] )}
		EOF
	}
	
	tags = {
		Name: "${local.projectName} Hosted Zone"
	}
}


resource "aws_route53_record" "production_soa" {
	zone_id = aws_route53_zone.production.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.production.name
	type = "SOA"
	ttl = "3600"
	records = [ "${aws_route53_delegation_set.production.name_servers[0]} awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400" ]
}


resource "aws_route53_record" "production_ns" {
	zone_id = aws_route53_zone.production.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.production.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_delegation_set.production.name_servers
}


resource "aws_route53_record" "production_staging_ns" {
	zone_id = aws_route53_zone.production.zone_id
	
	name = aws_route53_zone.staging.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_delegation_set.staging.name_servers
}



# 
# staging.vazprojects.com hosted zone.
#-------------------------------------------------------------------------------
resource "aws_route53_delegation_set" "staging" {
	
}


resource "aws_route53_zone" "staging" {
	name = "staging.${aws_route53_zone.production.name}"
	delegation_set_id = aws_route53_delegation_set.staging.id
	
	tags = {
		Name: "${local.projectName} Hosted Zone"
	}
}


resource "aws_route53_record" "staging_soa" {
	zone_id = aws_route53_zone.staging.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.staging.name
	type = "SOA"
	ttl = "3600"
	records = [ "${aws_route53_delegation_set.staging.name_servers[0]} awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400" ]
}


resource "aws_route53_record" "staging_ns" {
	zone_id = aws_route53_zone.staging.zone_id
	allow_overwrite = true
	
	name = aws_route53_zone.staging.name
	type = "NS"
	ttl = "3600"
	records = aws_route53_delegation_set.staging.name_servers
}