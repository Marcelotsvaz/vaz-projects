# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# perInstance.sh
sshKey='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7gGmj7aRlkjoPKKM35M+dG6gMkgD9IEZl2UVp6JYPs VAZ Projects SSH Key'
hostname="${hostname}"
user='nginx'
repositorySnapshot="${repository_snapshot}"
bucket="${bucket}"
AWS_DEFAULT_REGION="${region}"

# NGINX.
domainName="${domain}"

# dehydrated.sh
hostedZoneId="${hosted_zone_id}"
cloudfrontCertificateArn="${cloudfront_certificate_arn}"