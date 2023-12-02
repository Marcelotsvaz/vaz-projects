# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Lambda Function
#-------------------------------------------------------------------------------
module autoscaling_lambda {
	source = "gitlab.com/marcelotsvaz/lambda/aws"
	version = "~> 0.2.0"
	
	name = "${var.name} Auto Scaling"
	identifier = "${local.module_prefix}-autoscaling"
	
	source_dir = "${path.module}/files/src"
	handler = "autoscaling_lambda.main"
	timeout = 10
	environment = {
		hostedZoneId = aws_route53_record.a.zone_id
		recordName = aws_route53_record.a.name
		recordType = aws_route53_record.a.type
		recordTtl = aws_route53_record.a.ttl
	}
	
	policies = [ data.aws_iam_policy_document.lambda ]
}


data aws_iam_policy_document lambda {
	statement {
		sid = "autoscalingDescribeAutoScalingGroups"
		actions = [ "autoscaling:DescribeAutoScalingGroups" ]
		resources = [ "*" ]
	}
	
	statement {
		sid = "autoscalingDescribeInstances"
		actions = [ "ec2:DescribeInstances" ]
		resources = [ "*" ]
	}
	
	statement {
		sid = "autoscalingUpdateDns"
		actions = [
			"route53:ListResourceRecordSets",
			"route53:ChangeResourceRecordSets",
		]
		resources = [ var.private_hosted_zone.arn ]
	}
}


resource aws_lambda_permission main {
	function_name = module.autoscaling_lambda.function_name
	statement_id = "lambdaInvokeFunction"
	principal = "events.amazonaws.com"
	action = "lambda:InvokeFunction"
	source_arn = aws_cloudwatch_event_rule.main.arn
}



# 
# EventBridge
#-------------------------------------------------------------------------------
resource aws_cloudwatch_event_rule main {
	name = "${local.module_prefix}-autoscalingEvent"
	event_pattern = <<EOF
		{
			"source": [ "aws.autoscaling" ],
			"detail-type":
			[
				"EC2 Instance Launch Successful",
				"EC2 Instance Terminate Successful"
			],
			"detail":
			{
				"AutoScalingGroupName": [ "${local.autoscaling_group_name}" ]
			}
		}
	EOF
	
	tags = {
		Name = "${var.name} Auto Scaling Event Rule"
	}
}


resource aws_cloudwatch_event_target main {
	rule = aws_cloudwatch_event_rule.main.name
	arn = module.autoscaling_lambda.arn
}