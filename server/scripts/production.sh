#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# System
environment='production'
user='utl'
sshKey='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7gGmj7aRlkjoPKKM35M+dG6gMkgD9IEZl2UVp6JYPs VAZ Projects SSH Key'

# AWS
AWS_DEFAULT_REGION='sa-east-1'
instanceName='VAZ Projects Server'

# Network
hostname='vazprojects.com'
hostedZoneId='ZWFCO3AYVXVEU'

# Static Files
bucket='vaz-projects'
cloudfrontId='E2L2SVNZVPKVQV'
cloudfrontCertificateArn='arn:aws:acm:us-east-1:983585628015:certificate/220619d8-ef66-488f-b575-51704e578f8d'

# Django
DJANGO_SETTINGS_MODULE='settings.production'
PYTHONPYCACHEPREFIX='deployment/env/pycache'