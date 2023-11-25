# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource aws_route53_health_check main {
	fqdn = local.domain
	type = "HTTPS"
	
	regions = [
		"sa-east-1",
		"us-east-1",
		"eu-west-1",
	]
	
	tags = {
		Name = "${local.project_name} Health Check"
	}
}