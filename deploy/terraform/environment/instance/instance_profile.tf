# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource aws_iam_instance_profile main {
	name = "${var.prefix}-${var.identifier}"
	role = aws_iam_role.main.name
	
	tags = {
		Name: "${var.name} Instance Profile"
	}
}


resource aws_iam_role main {
	name = "${var.prefix}-${var.identifier}"
	assume_role_policy = data.aws_iam_policy_document.assume_role.json
	
	inline_policy {
		name = "${var.prefix}-${var.identifier}"
		
		policy = var.role_policy.json
	}
	
	tags = {
		Name: "${var.name} Role"
	}
}


data aws_iam_policy_document assume_role {
	statement {
		sid = "ec2AssumeRole"
		
		principals {
			type = "Service"
			identifiers = [ "ec2.amazonaws.com" ]
		}
		
		actions = [ "sts:AssumeRole" ]
	}
}