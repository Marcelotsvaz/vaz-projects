# AWS recipe:



# Network.
#-----------------------------------------------------------------------------------------------------------------------
VPC:
	Name: VAZ Projects VPC
	IPv4 CIDR block: 10.1.0.0/16
	IPv6 CIDR block: Amazon-provided IPv6 CIDR block
	Tags:
		Project: VAZ Projects

Route Table (Auto):
	Name: VAZ Projects Route Table
	Tags:
		Project: VAZ Projects
	
ACL (Auto):
	Name: VAZ Projects ACL
	Tags:
		Project: VAZ Projects

Subnet:
	Name: VAZ Projects Subnet C
	Tags:
		Project: VAZ Projects
	Region: sa-east-1c
	IPv4 block: 10.1.3.0/24
	IPv6 block: xxxx:xxxx:xxxx:xx03::/64
	Auto-assign public IPv4 and IPv6

Gateway:
	Name: VAZ Projects Internet Gateway
	Tags:
		Project: VAZ Projects
	Attach to VPC
	Add to route table:
		0.0.0.0/0 to Internet Gateway
		::/0 to Internet Gateway

Security Group (Auto):
	Tags:
		Name: VAZ Projects Production Security Group
		Project: VAZ Projects
	Delete default rule
	Allow inbound IPv4 and IPv6 connections from anywhere:
		SSH - IPv4
		HTTP - IPv4
		HTTPS - IPv4

Security Group:
	Name: VAZ Projects Staging Security Group
	Description: VAZ Projects Staging Security Group
	Tags:
		Name: VAZ Projects Staging Security Group
		Project: VAZ Projects
	Allow inbound IPv4 and IPv6 connections from anywhere:
		SSH - IPv4
		HTTP - IPv4
		HTTPS - IPv4



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

TODO: vaz-projects > Management > Lifecycle rules



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
# Staging.
Use case: EC2
Tags:
	Project: VAZ Projects
Name: vazProjectsStagingRole

Policies:
s3WriteAccess:
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "S3ListBucket",
			"Effect": "Allow",
			"Action": [
				"s3:ListBucket"
			],
			"Resource": [
				"arn:aws:s3:::vaz-projects",
				"arn:aws:s3:::vaz-projects-logs"
			]
		},
		{
			"Sid": "S3WriteAccess",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:GetObjectAcl",
				"s3:PutObject",
				"s3:PutObjectAcl",
				"s3:DeleteObject"
			],
			"Resource": [
				"arn:aws:s3:::vaz-projects/staging/*",
				"arn:aws:s3:::vaz-projects-logs/staging/*"
			]
		}
	]
}

route53ChangeRecordSets:
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Route53ChangeRecordSets",
			"Effect": "Allow",
			"Action": [
				"route53:ChangeResourceRecordSets",
				"route53:GetChange"
			],
			"Resource": [
				"arn:aws:route53:::hostedzone/ZWFCO3AYVXVEU",
				"arn:aws:route53:::change/*"
			]
		}
	]
}

# After certificates.
acmImportCertificate
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "ACMImportCertificate",
			"Effect": "Allow",
			"Action": [
				"acm:ImportCertificate"
			],
			"Resource": [
				"arn:aws:acm:us-east-1:983585628015:certificate/5fb0c8c9-790c-4bf2-8916-363f4be21463"
			]
		}
	]
}


# Production.
Use case: EC2
Tags:
	Project: VAZ Projects
Name: vazProjectsRole

Policies:
s3WriteAccess:
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "S3ListBucket",
			"Effect": "Allow",
			"Action": [
				"s3:ListBucket"
			],
			"Resource": [
				"arn:aws:s3:::vaz-projects",
				"arn:aws:s3:::vaz-projects-logs"
			]
		},
		{
			"Sid": "S3WriteAccess",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:GetObjectAcl",
				"s3:PutObject",
				"s3:PutObjectAcl",
				"s3:DeleteObject"
			],
			"Resource": [
				"arn:aws:s3:::vaz-projects/production/*",
				"arn:aws:s3:::vaz-projects-logs/production/*"
			]
		}
	]
}

route53ChangeRecordSets:
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Route53ChangeRecordSets",
			"Effect": "Allow",
			"Action": [
				"route53:ChangeResourceRecordSets",
				"route53:GetChange"
			],
			"Resource": [
				"arn:aws:route53:::hostedzone/ZWFCO3AYVXVEU",
				"arn:aws:route53:::change/*"
			]
		}
	]
}

# After certificates.
acmImportCertificate
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "ACMImportCertificate",
			"Effect": "Allow",
			"Action": [
				"acm:ImportCertificate"
			],
			"Resource": [
				"arn:aws:acm:us-east-1:983585628015:certificate/220619d8-ef66-488f-b575-51704e578f8d"
			]
		}
	]
}



# Route53 setup.
#-----------------------------------------------------------------------------------------------------------------------
Tags:
	Project: VAZ Projects

Zone file:
vazprojects.com.						3600	CAA		0 issue "letsencrypt.org"

vazprojects.com.						60		A		0.0.0.0
vazprojects.com.						60		AAAA	::

staging.vazprojects.com.				60		A		0.0.0.0
staging.vazprojects.com.				60		AAAA	::

vazprojects.com.						3600	TXT		"google-site-verification=x9tLElJp9QijYSWjI5x5LwQh5Am0r1xfHhF7iYeHSPs"

# Manual after certificates.
static-files.vazprojects.com.			-		A		???.cloudfront.net
static-files.vazprojects.com.			-		AAAA	???.cloudfront.net

static-files.staging.vazprojects.com.	-		A		???.cloudfront.net
static-files.staging.vazprojects.com.	-		AAAA	???.cloudfront.net

# Update TTL.
vazprojects.com.						3600	SOA		ns-1068.awsdns-05.org. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400
vazprojects.com.						3600	NS		ns-1068.awsdns-05.org.
vazprojects.com.						3600	NS		ns-527.awsdns-01.net.
vazprojects.com.						3600	NS		ns-1832.awsdns-37.co.uk.
vazprojects.com.						3600	NS		ns-282.awsdns-35.com.



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