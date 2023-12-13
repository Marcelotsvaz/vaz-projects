# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# resource aws_iam_user deploy {
# 	for_each = toset( [ "production", "staging" ] )
	
# 	name = "${local.project_code}-${each.value}-deployUser"
	
# 	tags = {
# 		Name = "${local.project_name} Deploy User"
# 	}
# }


# resource aws_iam_user_policy deploy {
# 	for_each = aws_iam_user.deploy
	
# 	name = "deployPolicy"
# 	user = each.value.name
# 	policy = data.aws_iam_policy_document.deploy.json
# }


# data aws_iam_policy_document deploy {
# 	statement {
# 		sid = "ec2Access"
# 		actions = [
# 			"ec2:RunInstances",
# 			"ec2:TerminateInstances",
# 			"ec2:DescribeInstances",
# 			"ec2:CreateTags",
# 			"ec2:CancelSpotInstanceRequests",
# 			"ec2:DescribeImages",
# 		]
# 		resources = [ "*" ]
# 	}
	
# 	statement {
# 		sid = "iamPassRole"
# 		actions = [ "iam:PassRole" ]
# 		resources = [
# 			"arn:aws:iam::983585628015:role/vazProjectsRole",
# 			"arn:aws:iam::983585628015:role/vazProjectsStagingRole",
# 		]
# 	}
	
# 	statement {
# 		sid = "cloudfrontInvalidate"
# 		actions = [ "cloudfront:CreateInvalidation" ]
# 		resources = [
# 			"arn:aws:cloudfront::983585628015:distribution/E14SOTLPYZH9C5",
# 			"arn:aws:cloudfront::983585628015:distribution/E2L2SVNZVPKVQV",
# 		]
# 	}
# }


# resource aws_iam_access_key deploy {
# 	for_each = aws_iam_user.deploy
	
# 	user = each.value.name
# }



# output credentials {
# 	value = [ for key in aws_iam_access_key.deploy: "Id: \"${key.id}\" Secret: \"${key.secret}\"" ]
# 	sensitive = true
# }