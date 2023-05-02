# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



resource aws_iam_instance_profile main {
	name = local.module_prefix
	role = aws_iam_role.main.name
	
	tags = {
		Name = "${var.name} Instance Profile"
	}
}


resource aws_iam_role main {
	name = local.module_prefix
	assume_role_policy = data.aws_iam_policy_document.assume_role.json
	managed_policy_arns = []
	
	inline_policy {
		name = local.module_prefix
		policy = var.role_policy.json
	}
	
	tags = {
		Name = "${var.name} Role"
	}
}


data aws_iam_policy_document assume_role {
	statement {
		sid = "ec2AssumeRole"
		actions = [ "sts:AssumeRole" ]
		principals {
			type = "Service"
			identifiers = [ "ec2.amazonaws.com" ]
		}
	}
}



resource aws_iam_role fleet {
	name = "${local.module_prefix}-fleet"
	assume_role_policy = data.aws_iam_policy_document.fleet_assume_role.json
	managed_policy_arns = [ "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole" ]
	
	inline_policy {}
	
	tags = {
		Name = "${var.name} Fleet Role"
	}
}



data aws_iam_policy_document fleet_assume_role {
	statement {
		sid = "spotFleetAssumeRole"
		actions = [ "sts:AssumeRole" ]
		principals {
			type = "Service"
			identifiers = [ "spotfleet.amazonaws.com" ]
		}
	}
}