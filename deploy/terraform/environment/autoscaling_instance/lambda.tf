# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



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
		sid = "autoscalingCompleteLifecycle"
		
		actions = [ "autoscaling:CompleteLifecycleAction" ]
		
		resources = [ aws_autoscaling_group.autoscaling_group.arn ]
	}
}



# 
# Lambda Function.
#-------------------------------------------------------------------------------
resource "aws_lambda_function" "autoscaling_lambda" {
	function_name = "${var.unique_identifier}-autoscalingLambda"
	filename = "autoscaling_lambda.zip"
	handler = "autoscaling_lambda.lambda_handler"
	source_code_hash = data.archive_file.autoscaling_lambda.output_base64sha256
	runtime = "python3.9"
	
	role = aws_iam_role.autoscaling_lambda_role.arn
	
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
				"AutoScalingGroupName": [ "${aws_autoscaling_group.autoscaling_group.name}" ]
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