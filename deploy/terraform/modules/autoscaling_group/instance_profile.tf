# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource aws_iam_instance_profile main {
	name = local.module_prefix
	role = aws_iam_role.main.name
	
	tags = {
		Name: "${var.name} Instance Profile"
	}
}


resource aws_iam_role main {
	name = local.module_prefix
	assume_role_policy = data.aws_iam_policy_document.instance_assume_role.json
	managed_policy_arns = []
	
	inline_policy {
		name = local.module_prefix
		policy = var.role_policy.json
	}
	
	tags = {
		Name: "${var.name} Role"
	}
}


data aws_iam_policy_document instance_assume_role {
	statement {
		sid = "ec2AssumeRole"
		actions = [ "sts:AssumeRole" ]
		principals {
			type = "Service"
			identifiers = [ "ec2.amazonaws.com" ]
		}
	}
}