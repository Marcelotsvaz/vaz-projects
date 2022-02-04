#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# deploy.sh
cloudfrontId=${cloudfront_id}

# perInstance.sh
AWS_DEFAULT_REGION=${region}
user=utl
sshKey=ssh-ed25519\ AAAAC3NzaC1lZDI1NTE5AAAAIH7gGmj7aRlkjoPKKM35M+dG6gMkgD9IEZl2UVp6JYPs\ VAZ\ Projects\ SSH\ Key
repositorySnapshot=${repository_snapshot}
applicationImage=${application_image}

# perBoot.sh
hostedZoneId=${hosted_zone_id}

# Django application.
DJANGO_SETTINGS_MODULE=settings.${environment}
domainName=${domain}
bucket=${bucket}

# Dehydrated
cloudfrontCertificateArn=${cloudfront_certificate_arn}