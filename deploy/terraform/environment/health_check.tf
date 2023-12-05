# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource aws_route53_health_check main {
	fqdn = local.domain
	type = "HTTPS"
	port = 443
	request_interval = 30
	
	regions = [
		"sa-east-1",
		"us-east-1",
		"eu-west-1",
	]
	
	tags = {
		Name = "${local.project_name} Health Check"
	}
}


resource aws_cloudwatch_metric_alarm health_check {
	provider = aws.global
	
	alarm_name = "${local.project_name} Health Check Alarm"
	alarm_description = "Triggers when the Route53 health check of the application HTTPS endpoint fails."
	
	# Metric.
	namespace = "AWS/Route53"
	metric_name = "HealthCheckStatus"
	dimensions = { HealthCheckId = aws_route53_health_check.main.id }
	statistic = "Minimum"
	period = 60
	
	# Condition.
	comparison_operator = "LessThanThreshold"
	threshold = 1
	evaluation_periods = 1
	
	# Actions
	alarm_actions = [ aws_sns_topic.health_check.arn ]
	ok_actions = [ aws_sns_topic.health_check.arn ]
	
	tags = {
		Name = "${local.project_name} Health Check Alarm"
	}
}


resource aws_sns_topic health_check {
	provider = aws.global
	
	name = "${local.project_prefix}-alarm"
	
	tags = {
		Name = "${local.project_name} Health Check Topic"
	}
}


resource aws_sns_topic_subscription health_check {
	provider = aws.global
	
	topic_arn = aws_sns_topic.health_check.arn
	protocol = "email"
	endpoint = local.admin_email
}