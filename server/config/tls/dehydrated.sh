#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Abort on error.
set -e

cd /home/${user}/deployment/tls
config=/home/${user}/server/config/tls/dehydrated.conf

dehydrated -f ${config} -p accountKey.pem -s websiteCsr.pem --accept-terms > website.crt
dehydrated -f ${config} -p accountKey.pem -s cloudfrontCsr.pem --accept-terms > cloudfront.crt

# Upload the Cloudfront certificate to ACM, somehow.
cat cloudfront.crt | python -c 'import sys, re, subprocess; match = re.search( r"(-[\S\s]*?)\s\s(-[\S\s]*)", sys.stdin.read() ); subprocess.run( [ "aws" ] + match.expand( r"acm  --region  us-east-1  import-certificate  --certificate-arn  '${cloudfrontCertificateArn}'  --certificate  \1  --certificate-chain  \2  --private-key  file://cloudfrontKey.pem"  ).split("  ") )'

aws s3 cp website.crt s3://${bucket}/${environment}/deployment/tls/ --no-progress
aws s3 cp cloudfront.crt s3://${bucket}/${environment}/deployment/tls/ --no-progress