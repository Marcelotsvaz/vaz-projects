#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "aws_route53_zone" "hosted_zone" {
	name = "staging.vazprojects.com"
}