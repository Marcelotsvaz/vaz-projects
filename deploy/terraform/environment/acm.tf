# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data "aws_acm_certificate" "cloudfront" {
	provider = aws.us_east_1
	
	domain = local.static_files_domain
	key_types = [ "EC_prime256v1" ]
}