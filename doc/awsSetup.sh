# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# 
# Account
#---------------------------------------------------------------------------------------------------
Setup account
Account Alias: marcelotsvaz
Update address
Setup alternate contacts
Add two-factor authentication to root user
Add access to billing data

IAM User:
	Username: Marcelotsvaz
	Create group:
		Name: Administrator
		Permissions: AdministratorAccess
	Add two-factor authentication

Enable EC2 EBS encryption



# 
# Certificates
#---------------------------------------------------------------------------------------------------
mkdir -p /home/${user}/deployment/tls/ && cd ${_}
config=/home/${user}/loadBalancer/config/tls/dehydrated.conf

Account:
	dehydrated -f ${config} --register --accept-terms

Server:
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out websiteKey.pem
	openssl req -new -subj / -addext "subjectAltName = DNS:${domain}, DNS:${monitoringDomain}" -key websiteKey.pem -sha512 -out websiteCsr.pem
	dehydrated -f ${config} -p accountKey.pem -s websiteCsr.pem --accept-terms > website.crt

CloudFront:
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out cloudfrontKey.pem
	openssl req -new -subj / -addext "subjectAltName = DNS:${staticFilesDomain}" -key cloudfrontKey.pem -sha512 -out cloudfrontCsr.pem
	dehydrated -f ${config} -p accountKey.pem -s cloudfrontCsr.pem --accept-terms > cloudfront.crt



# 
# S3 Buckets
#---------------------------------------------------------------------------------------------------
cd deployment/

Create bucket
	Name: VAZ Projects Bucket
	Project: VAZ Projects
	Environment: Production
aws s3 cp secrets.env s3://${bucket}/deployment/
aws s3 sync tls/ s3://${bucket}/deployment/tls/

Create bucket
	Name: VAZ Projects Logs Bucket
	Project: VAZ Projects
	Environment: Production