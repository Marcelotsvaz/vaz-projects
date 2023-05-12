# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



data aws_s3_object cloudfront_key {
	bucket = data.aws_s3_bucket.data.bucket
	key = "deployment/tls/cloudfrontKey.pem"
	
	depends_on = [ aws_s3_bucket.data ]
}


data aws_s3_object cloudfront_certificate {
	bucket = data.aws_s3_bucket.data.bucket
	key = "deployment/tls/cloudfront.crt"
	
	depends_on = [ aws_s3_bucket.data ]
}


locals {
	cloudfront_certificate = split( "\n\n", data.aws_s3_object.cloudfront_certificate.body )
	cloudfront_certificate_body = local.cloudfront_certificate[0]
	cloudfront_certificate_chain = join( "\n", slice( local.cloudfront_certificate, 1, 3 ) )
}


resource aws_acm_certificate cloudfront {
	provider = aws.us_east_1
	
	private_key = data.aws_s3_object.cloudfront_key.body
	certificate_body = local.cloudfront_certificate_body
	certificate_chain = local.cloudfront_certificate_chain
	
	# Certificate is renewed by the load-balancer instance.
	lifecycle {
		ignore_changes = [
			private_key,
			certificate_body,
			certificate_chain,
		]
	}
	
	tags = {
		Name = "${local.project_name} CloudFront Certificate"
	}
}