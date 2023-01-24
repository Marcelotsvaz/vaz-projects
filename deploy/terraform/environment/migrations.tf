# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



moved {
	from = aws_s3_bucket.bucket
	to = aws_s3_bucket.data
}

moved {
	from = aws_s3_bucket.logs_bucket
	to = aws_s3_bucket.logs
}