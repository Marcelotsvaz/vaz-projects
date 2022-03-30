# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource "aws_iam_instance_profile" "instance_profile" {
	name = "${var.unique_identifier}-instanceProfile"
	role = aws_iam_role.instance_role.name
	
	tags = {
		Name: "${var.name} Instance Profile"
	}
}


resource "aws_iam_role" "instance_role" {
	name = "${var.unique_identifier}-role"
	assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
	
	inline_policy {
		name = "${var.unique_identifier}-rolePolicy"
		
		policy = var.role_policy.json
	}
	
	tags = {
		Name: "${var.name} Role"
	}
}


data "aws_iam_policy_document" "assume_role_policy" {
	statement {
		sid = "ec2AssumeRole"
		
		principals {
			type = "Service"
			identifiers = [ "ec2.amazonaws.com" ]
		}
		
		actions = [ "sts:AssumeRole" ]
	}
}