#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



set -e	# Abort on error.



# 
# Certificates
#---------------------------------------------------------------------------------------------------
mkdir -p ../../../deployment/${environment}/tls/ && cd ${_}
config=../../../loadBalancer/config/tls/dehydrated.conf


# Account.
dehydrated --config ${config} --register --accept-terms

# Application.
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out websiteKey.pem
openssl req -new -subj / -addext "subjectAltName = DNS:${domain}, DNS:${monitoringDomain}" -key websiteKey.pem -sha512 -out websiteCsr.pem
dehydrated --config ${config} --signcsr websiteCsr.pem > website.crt

# CloudFront.
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out cloudfrontKey.pem
openssl req -new -subj / -addext "subjectAltName = DNS:${staticFilesDomain}" -key cloudfrontKey.pem -sha512 -out cloudfrontCsr.pem
dehydrated --config ${config} --signcsr cloudfrontCsr.pem > cloudfront.crt



# 
# Secrets
#---------------------------------------------------------------------------------------------------
function generateSecret
{
	local length="${1-128}"
	
	cat /dev/urandom | tr -dc A-Za-z0-9 | head -c ${length}
}


cd ..
#-------------------------------------------------------------------------------
cat > secrets.env <<- EOF
	#
	# VAZ Projects
	#
	#
	# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>
	
	
	
	# Django application.
	djangoSecretKey='$(generateSecret)'
	
	# Elasticsearch.
	ELASTIC_PASSWORD='$(generateSecret)'
	
	# Postgres.
	POSTGRES_PASSWORD='$(generateSecret)'
	
	# Grafana.
	GF_SECURITY_ADMIN_PASSWORD='$(generateSecret 32)'
EOF
#-------------------------------------------------------------------------------



# 
# Upload to S3
#---------------------------------------------------------------------------------------------------
aws s3 sync tls/ s3://${bucket}/deployment/tls/ --no-progress --content-type text/plain
aws s3 cp secrets.env s3://${bucket}/deployment/ --no-progress --content-type text/plain



# 
# Clean-up
#---------------------------------------------------------------------------------------------------
cd ..
rm -r ${environment}/