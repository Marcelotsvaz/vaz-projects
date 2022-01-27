#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Account.
#-----------------------------------------------------------------------------------------------------------------------
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



# Create IAM roles.
#-----------------------------------------------------------------------------------------------------------------------
# Deploy.
{
	"Version": "2012-10-17",
	"Statement":
	[
		{
			"Sid": "ec2Access",
			"Effect": "Allow",
			"Action":
			[
				"ec2:RunInstances",
				"ec2:TerminateInstances",
				"ec2:DescribeInstances",
				"ec2:CreateTags",
				"ec2:CancelSpotInstanceRequests",
				"ec2:DescribeImages"
			],
			"Resource": [ "*" ]
		},
		
		{
			"Sid": "iamPassRole",
			"Effect": "Allow",
			"Action": [ "iam:PassRole" ],
			"Resource":
			[
				"arn:aws:iam::983585628015:role/vazProjectsRole",
				"arn:aws:iam::983585628015:role/vazProjectsStagingRole"
			]
		},
		
		{
			"Sid": "cloudfrontInvalidate",
			"Effect": "Allow",
			"Action": [ "cloudfront:CreateInvalidation" ],
			"Resource":
			[
				"arn:aws:cloudfront::983585628015:distribution/E14SOTLPYZH9C5",
				"arn:aws:cloudfront::983585628015:distribution/E2L2SVNZVPKVQV"
			]
		},
	]
}



# Certificate setup.
#-----------------------------------------------------------------------------------------------------------------------
TODO: better keys and update certificate.sh

mkdir /home/${user}/deployment/tls
cd /home/${user}/deployment/tls
config=/home/${user}/server/config/tls/dehydrated.conf

# Staging.
export env file
Account:
	dehydrated -f ${config} --register --accept-terms

Server:
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out websiteKey.pem
	openssl req -new -subj / -addext 'subjectAltName = DNS:staging.vazprojects.com' -key websiteKey.pem -sha512 -out websiteCsr.pem
	dehydrated -f ${config} -p accountKey.pem -s websiteCsr.pem --accept-terms > website.crt

Cloudfront:
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out cloudfrontKey.pem
	openssl req -new -subj / -addext 'subjectAltName = DNS:static-files.staging.vazprojects.com' -key cloudfrontKey.pem -sha512 -out cloudfrontCsr.pem
	dehydrated -f ${config} -p accountKey.pem -s cloudfrontCsr.pem --accept-terms > cloudfront.crt

# Upload to S3.
aws s3 cp accountKey.pem s3://vaz-projects/staging/deployment/tls/
aws s3 cp websiteKey.pem s3://vaz-projects/staging/deployment/tls/
aws s3 cp websiteCsr.pem s3://vaz-projects/staging/deployment/tls/
aws s3 cp website.crt s3://vaz-projects/staging/deployment/tls/
aws s3 cp cloudfrontKey.pem s3://vaz-projects/staging/deployment/tls/
aws s3 cp cloudfrontCsr.pem s3://vaz-projects/staging/deployment/tls/
aws s3 cp cloudfront.crt s3://vaz-projects/staging/deployment/tls/

Upload to ACM
	Project: VAZ Projects
	Name: VAZ Projects Staging Cloudfront Certificate



# Production.
export env file
Account:
	dehydrated -f ${config} --register --accept-terms

Server:
	openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out websiteKey.pem
	openssl req -new -subj / -addext 'subjectAltName = DNS:vazprojects.com' -key websiteKey.pem -sha512 -out websiteCsr.pem
	dehydrated -f ${config} -p accountKey.pem -s websiteCsr.pem --accept-terms > website.crt

Cloudfront:
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out cloudfrontKey.pem
	openssl req -new -subj / -addext 'subjectAltName = DNS:static-files.vazprojects.com' -key cloudfrontKey.pem -sha512 -out cloudfrontCsr.pem
	dehydrated -f ${config} -p accountKey.pem -s cloudfrontCsr.pem --accept-terms > cloudfront.crt

# Upload to S3.
aws s3 cp accountKey.pem s3://vaz-projects/production/deployment/tls/
aws s3 cp websiteKey.pem s3://vaz-projects/production/deployment/tls/
aws s3 cp websiteCsr.pem s3://vaz-projects/production/deployment/tls/
aws s3 cp website.crt s3://vaz-projects/production/deployment/tls/
aws s3 cp cloudfrontKey.pem s3://vaz-projects/production/deployment/tls/
aws s3 cp cloudfrontCsr.pem s3://vaz-projects/production/deployment/tls/
aws s3 cp cloudfront.crt s3://vaz-projects/production/deployment/tls/

Upload to ACM
	Project: VAZ Projects
	Name: VAZ Projects Cloudfront Certificate



# Upload files.
#-----------------------------------------------------------------------------------------------------------------------
aws s3 cp deployment/secrets.py s3://vaz-projects/staging/deployment/
aws s3 cp deployment/secrets.py s3://vaz-projects/production/deployment/