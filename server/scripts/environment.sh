#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# System
environment="${environment}"
user='utl'
sshKey='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7gGmj7aRlkjoPKKM35M+dG6gMkgD9IEZl2UVp6JYPs VAZ Projects SSH Key'

# AWS
AWS_DEFAULT_REGION="${region}"

# Network
hostname="${domain}"
hostedZoneId="${hosted_zone_id}"

# Static Files
bucket="${bucket}"
cloudfrontId="${cloudfront_id}"
cloudfrontCertificateArn="${cloudfront_certificate_arn}"

# Django
DJANGO_SETTINGS_MODULE="settings.${environment}"
PYTHONPYCACHEPREFIX='deployment/env/pycache'