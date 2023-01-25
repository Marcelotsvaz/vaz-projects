# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Lambda Function
#-------------------------------------------------------------------------------
resource aws_lambda_function main {
	function_name = local.lambda_function_name
	role = aws_iam_role.lambda.arn
	
	runtime = "python3.9"
	filename = data.archive_file.main.output_path
	source_code_hash = data.archive_file.main.output_base64sha256
	handler = "autoscaling_lambda.main"
	timeout = 10
	
	environment {
		variables = {
			hostedZoneId = aws_route53_record.a.zone_id
			recordName = aws_route53_record.a.name
			recordType = aws_route53_record.a.type
			recordTtl = aws_route53_record.a.ttl
		}
	}
	
	# Make sure the log group is created before the function because we removed the implicit dependency.
	depends_on = [ aws_cloudwatch_log_group.main ]
	
	tags = {
		Name = "${var.name} Auto Scaling Lambda"
	}
}


data archive_file main {
	type = "zip"
	source_file = "${path.module}/autoscaling_lambda.py"
	output_path = "../../../deployment/${var.prefix}/${var.identifier}/autoscaling_lambda.zip"
}


resource aws_lambda_permission main {
	function_name = aws_lambda_function.main.function_name
	statement_id = "lambdaInvokeFunction"
	principal = "events.amazonaws.com"
	action = "lambda:InvokeFunction"
	source_arn = aws_cloudwatch_event_rule.main.arn
}


resource aws_cloudwatch_log_group main {
	name = "/aws/lambda/${local.lambda_function_name}"
	
	tags = {
		Name = "${var.name} Auto Scaling Lambda Log Group"
	}
}



# 
# Lambda IAM Role
#-------------------------------------------------------------------------------
resource aws_iam_role lambda {
	name = "${var.prefix}-${var.identifier}-autoscalingLambda"
	assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
	
	inline_policy {
		name = "${var.prefix}-${var.identifier}-autoscalingLambda"
		
		policy = data.aws_iam_policy_document.lambda.json
	}
	
	tags = {
		Name: "${var.name} Auto Scaling Lambda Role"
	}
}


data aws_iam_policy_document lambda_assume_role {
	statement {
		sid = "lambdaAssumeRole"
		
		principals {
			type = "Service"
			identifiers = [ "lambda.amazonaws.com" ]
		}
		
		actions = [ "sts:AssumeRole" ]
	}
}


data aws_iam_policy_document lambda {
	# Used in autoscaling_lambda.py.
	statement {
		sid = "autoscalingDescribeAutoScalingGroups"
		
		actions = [ "autoscaling:DescribeAutoScalingGroups" ]
		
		resources = [ "*" ]
	}
	
	# Used in autoscaling_lambda.py.
	statement {
		sid = "ec2DescribeInstances"
		
		actions = [ "ec2:DescribeInstances" ]
		
		resources = [ "*" ]
	}
	
	# Used in autoscaling_lambda.py.
	statement {
		sid = "route53ChangeRecordSets"
		
		actions = [
			"route53:ListResourceRecordSets",
			"route53:ChangeResourceRecordSets",
		]
		
		resources = [ var.private_hosted_zone.arn ]
	}
	
	# Used by Lambda.
	statement {
		sid = "cloudwatchWriteLogs"
		
		actions = [
			"logs:CreateLogStream",
			"logs:PutLogEvents",
		]
		
		resources = [ "${aws_cloudwatch_log_group.main.arn}:*" ]
	}
}



# 
# EventBridge
#-------------------------------------------------------------------------------
resource aws_cloudwatch_event_rule main {
	name = "${var.prefix}-${var.identifier}-autoscalingEvent"
	event_pattern = <<EOF
		{
			"source": [ "aws.autoscaling" ],
			"detail-type": [ "EC2 Instance Launch Successful", "EC2 Instance Terminate Successful" ],
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
	arn = aws_lambda_function.main.arn
}