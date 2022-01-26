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



# Create buckets.
#-----------------------------------------------------------------------------------------------------------------------
Name: vaz-projects / vaz-projects-logs
Region sa-east-1
Block all public access
Enable versioning
Tags:
	Project: VAZ Projects
Enable encryption (SSE-S3)

vaz-projects > Properties > Server access logging
Enabled (s3://vaz-projects-logs/s3/)

# After creating Cloudfront distribuition.
vaz-projects > Permissions > Bucket policy
{
	"Version": "2008-10-17",
	"Id": "PolicyForCloudFrontPrivateContent",
	"Statement": [
		{
			"Sid": "S3-Production",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity EBYS6AYBEDX4C"
			},
			"Action": "s3:GetObject",
			"Resource": [
				"arn:aws:s3:::vaz-projects/production/static/*",
				"arn:aws:s3:::vaz-projects/production/media/*"
			]
		},
		{
			"Sid": "S3-Staging",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E1LOKSB1MRE35F"
			},
			"Action": "s3:GetObject",
			"Resource": [
				"arn:aws:s3:::vaz-projects/staging/static/*",
				"arn:aws:s3:::vaz-projects/staging/media/*"
			]
		}
	]
}

vaz-projects > Permissions > Cross-origin resource sharing (CORS)
[
	{
		"AllowedHeaders": [],
		"AllowedMethods": [
			"GET"
		],
		"AllowedOrigins": [
			"https://vazprojects.com"
		],
		"ExposeHeaders": []
	},
	{
		"AllowedHeaders": [],
		"AllowedMethods": [
			"GET"
		],
		"AllowedOrigins": [
			"https://staging.vazprojects.com"
		],
		"ExposeHeaders": []
	}
]



# Create Cloudfront distribuition.
#-----------------------------------------------------------------------------------------------------------------------
# Staging.
Origin:
	Domain: vaz-projects.s3.sa-east-1.amazonaws.com
	Path: /staging/static
	Name: S3-Staging-Static
	Yes use OAI
		Create: VAZ Projects Staging Origin Access Identity
Default cache behavior:
	Viewer protocol policy: HTTPS Only
Settings:
	# After certificate.
	Alternate domain name (CNAME): static-files.staging.vazprojects.com
	# After certificate.
	Custom SSL certificate: static-files.staging.vazprojects.com
	Standard logging:
		Bucket: vaz-projects-logs
		Prefix: staging/cloudfront/
	Description: VAZ Projects Staging Distribuition

New origin:
	Domain: vaz-projects.s3.sa-east-1.amazonaws.com
	Path: /staging/media
	Name: S3-Staging-Media
	Yes use OAI (VAZ Projects Staging Origin Access Identity)

New origin group:
	Origins: Static + Media
	Name: S3-Staging
	Failover criteria: 403 - Forbidden

Edit default behaviour:
	Origin and origin groups: S3-Staging

Create favicon behavior:
	Pattern: favicon.ico
	Origin and origin groups: S3-Staging-Static
	Viewer protocol policy: HTTPS Only
	Origin request: Lambda@Edge (arn:aws:lambda:us-east-1:983585628015:function:FaviconRedirect:3)

Tags:
	Project: VAZ Projects


# Production.
Origin:
	Domain: vaz-projects.s3.sa-east-1.amazonaws.com
	Path: /production/static
	Name: S3-Production-Static
	Yes use OAI
		Create: VAZ Projects Origin Access Identity
Default cache behavior:
	Viewer protocol policy: HTTPS Only
Settings:
	# After certificate.
	Alternate domain name (CNAME): static-files.vazprojects.com
	# After certificate.
	Custom SSL certificate: static-files.vazprojects.com
	Standard logging:
		Bucket: vaz-projects-logs
		Prefix: production/cloudfront/
	Description: VAZ Projects Distribuition

New origin:
	Domain: vaz-projects.s3.sa-east-1.amazonaws.com
	Path: /production/media
	Name: S3-Production-Media
	Yes use OAI (VAZ Projects Origin Access Identity)

New origin group:
	Origins: Static + Media
	Name: S3-Production
	Failover criteria: 403 - Forbidden

Edit default behaviour:
	Origin and origin groups: S3-Production

Create favicon behavior:
	Pattern: favicon.ico
	Origin and origin groups: S3-Production-Static
	Viewer protocol policy: HTTPS Only
	Origin request: Lambda@Edge (arn:aws:lambda:us-east-1:983585628015:function:FaviconRedirect:3)

Tags:
	Project: VAZ Projects


# Go back to bucket permissions.



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

# Go back to Role permissions.
# Go back to Cloudfront certificate and CNAME.
# Go back to Route53 alias.


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

# Go back to Role permissions.
# Go back to Cloudfront certificate and CNAME.
# Go back to Route53 alias.



# Upload files.
#-----------------------------------------------------------------------------------------------------------------------
aws s3 cp deployment/secrets.py s3://vaz-projects/staging/deployment/
aws s3 cp deployment/secrets.py s3://vaz-projects/production/deployment/