# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .staging import *



# General
#---------------------------------------
ENVIRONMENT = 'local'


# Static and media files
#---------------------------------------
STATIC_URL = f'http://{environ["staticFilesDomain"]}:9000/{AWS_STORAGE_BUCKET_NAME}/'
MEDIA_URL = f'http://{environ["staticFilesDomain"]}:9000/{AWS_STORAGE_BUCKET_NAME}/'
AWS_S3_SECURE_URLS = False


# Security
#---------------------------------------
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False
LANGUAGE_COOKIE_SECURE = False