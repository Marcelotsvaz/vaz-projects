# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Lambda Function.
#-------------------------------------------------------------------------------
resource "aws_lambda_function" "autoscaling_lambda" {
	function_name = local.autoscaling_lambda_function_name
	role = aws_iam_role.autoscaling_lambda_role.arn
	
	runtime = "python3.9"
	filename = "autoscaling_lambda.zip"
	source_code_hash = data.archive_file.autoscaling_lambda.output_base64sha256
	handler = "autoscaling_lambda.main"
	
	environment {
		variables = {
			hostedZoneId = aws_route53_record.a.zone_id
			recordName = aws_route53_record.a.name
			recordType = aws_route53_record.a.type
			recordTtl = aws_route53_record.a.ttl
		}
	}
	
	# Make sure the log group is created before the function because we removed the implicit dependency.
	depends_on = [ aws_cloudwatch_log_group.autoscaling_lambda_log_group ]
	
	tags = {
		Name = "${var.name} Auto Scaling Lambda"
	}
}


data "archive_file" "autoscaling_lambda" {
	type = "zip"
	source_file = "${path.module}/autoscaling_lambda.py"
	output_path = "autoscaling_lambda.zip"
}


resource "aws_lambda_permission" "autoscaling_lambda_resource_policy" {
	function_name = aws_lambda_function.autoscaling_lambda.function_name
	statement_id = "lambdaInvokeFunction"
	principal = "events.amazonaws.com"
	action = "lambda:InvokeFunction"
	source_arn = aws_cloudwatch_event_rule.autoscaling_event_rule.arn
}


resource "aws_cloudwatch_log_group" "autoscaling_lambda_log_group" {
	name = "/aws/lambda/${local.autoscaling_lambda_function_name}"
	
	tags = {
		Name = "${var.name} Auto Scaling Lambda Log Group"
	}
}



# 
# Lambda IAM Role.
#-------------------------------------------------------------------------------
resource "aws_iam_role" "autoscaling_lambda_role" {
	name = "${var.unique_identifier}-autoscalingLambdaRole"
	assume_role_policy = data.aws_iam_policy_document.autoscaling_lambda_assume_role_policy.json
	
	inline_policy {
		name = "${var.unique_identifier}-autoscalingLambdaRolePolicy"
		
		policy = data.aws_iam_policy_document.autoscaling_lambda_role_policy.json
	}
	
	tags = {
		Name: "${var.name} Auto Scaling Lambda Role"
	}
}


data "aws_iam_policy_document" "autoscaling_lambda_assume_role_policy" {
	statement {
		sid = "lambdaAssumeRole"
		
		principals {
			type = "Service"
			identifiers = [ "lambda.amazonaws.com" ]
		}
		
		actions = [ "sts:AssumeRole" ]
	}
}


data "aws_iam_policy_document" "autoscaling_lambda_role_policy" {
	statement {
		sid = "autoscalingDescribeAutoScalingGroups"
		
		actions = [ "autoscaling:DescribeAutoScalingGroups" ]
		
		resources = [ "*" ]
	}
	
	statement {
		sid = "ec2DescribeInstances"
		
		actions = [ "ec2:DescribeInstances" ]
		
		resources = [ "*" ]
	}
	
	statement {
		sid = "route53ChangeRecordSets"
		
		actions = [
			"route53:ListResourceRecordSets",
			"route53:ChangeResourceRecordSets",
		]
		
		resources = [ var.private_hosted_zone.arn ]
	}
	
	statement {
		sid = "cloudwatchWriteLogs"
		
		actions = [
			"logs:CreateLogStream",
			"logs:PutLogEvents",
		]
		
		resources = [ "${aws_cloudwatch_log_group.autoscaling_lambda_log_group.arn}:*" ]
	}
}



# 
# EventBridge.
#-------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "autoscaling_event_rule" {
	name = "${var.unique_identifier}-autoscalingEventRule"
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


resource "aws_cloudwatch_event_target" "autoscaling_event_target" {
	rule = aws_cloudwatch_event_rule.autoscaling_event_rule.name
	arn = aws_lambda_function.autoscaling_lambda.arn
}