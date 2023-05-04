#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Abort on error.
set -e

cd /home/${user}/deployment/tls/
config=../../loadBalancer/config/tls/dehydrated.conf

tempFile=$(mktemp)
# Run in a sub-shell because `set -e` doesn't trigger with `&&`.
(dehydrated --config ${config} --signcsr websiteCsr.pem > ${tempFile} && cp ${tempFile} website.crt)
(dehydrated --config ${config} --signcsr cloudfrontCsr.pem > ${tempFile} && cp ${tempFile} cloudfront.crt)

aws s3 sync . s3://${bucket}/deployment/tls/ --no-progress

# Update the CloudFront certificate in ACM, somehow.
cat cloudfront.crt | python -c 'import sys, re, subprocess; match = re.search( r"(-[\S\s]*?)\s\s(-[\S\s]*)", sys.stdin.read() ); subprocess.run( [ "aws" ] + match.expand( r"acm  --region  us-east-1  import-certificate  --certificate-arn  '${cloudfrontCertificateArn}'  --certificate  \1  --certificate-chain  \2  --private-key  file://cloudfrontKey.pem"  ).split("  ") )'