#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# System
environment='staging'
user='utl'
sshKey='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7gGmj7aRlkjoPKKM35M+dG6gMkgD9IEZl2UVp6JYPs VAZ Projects SSH Key'

# AWS
AWS_DEFAULT_REGION='sa-east-1'

# Network
hostname='staging.vazprojects.com'
hostedZoneId='ZWFCO3AYVXVEU'

# Static Files
bucket='vaz-projects'
cloudfrontId='E14SOTLPYZH9C5'
cloudfrontCertificateArn='arn:aws:acm:us-east-1:983585628015:certificate/5fb0c8c9-790c-4bf2-8916-363f4be21463'

# Django
DJANGO_SETTINGS_MODULE='settings.staging'
PYTHONPYCACHEPREFIX='deployment/env/pycache'