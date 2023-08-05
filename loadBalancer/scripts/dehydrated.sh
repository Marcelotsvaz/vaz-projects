#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



set -o errexit

cd /home/${user}/deployment/tls/
config='../../loadBalancer/config/tls/dehydrated.conf'

tempFile=$(mktemp)
# Run in a sub-shell because `set -o errexit` doesn't trigger with `&&`.
(dehydrated --config ${config} --signcsr websiteCsr.pem > ${tempFile} && cp ${tempFile} website.crt)
(dehydrated --config ${config} --signcsr cloudfrontCsr.pem > ${tempFile} && cp ${tempFile} cloudfront.crt)

aws s3 sync . s3://${bucket}/deployment/tls/ --no-progress --content-type text/plain

# Update the CloudFront certificate in ACM, somehow.
cat cloudfront.crt | python <(cat <<- EOF
	import sys
	import re
	import subprocess
	
	match = re.search( r'(-[\S\s]*?)\s\s(-[\S\s]*)', sys.stdin.read() )
	
	subprocess.run( [
		'aws',
		'acm',
		'--region',
		'us-east-1',
		'import-certificate',
		'--certificate-arn',
		'${cloudfrontCertificateArn}',
		'--certificate',
		match[1],
		'--certificate-chain',
		match[2],
		'--private-key',
		'file://cloudfrontKey.pem',
	] )
EOF
)