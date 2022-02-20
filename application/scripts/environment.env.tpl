# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# perInstance.sh
sshKey='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7gGmj7aRlkjoPKKM35M+dG6gMkgD9IEZl2UVp6JYPs VAZ Projects SSH Key'
hostname="${hostname}"
user='django'
repositorySnapshot="${repository_snapshot}"
AWS_DEFAULT_REGION="${region}"
applicationImage="${application_image}"

# Django application.
DJANGO_SETTINGS_MODULE=settings.${environment}
domainName="${domain}"
bucket=${bucket}