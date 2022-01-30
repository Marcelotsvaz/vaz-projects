#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .base import *
from .secrets import *



# General
#---------------------------------------
ENVIRONMENT = 'production'


# Static and media files
#---------------------------------------
STATICFILES_STORAGE = 'commonApp.backends.StaticCloudfrontStorage'
DEFAULT_FILE_STORAGE = 'commonApp.backends.CloudfrontStorage'

STATIC_URL = f'https://static-files.{environ["domainName"]}/'
STATIC_ROOT = 'static/'

MEDIA_URL = f'https://static-files.{environ["domainName"]}/'
MEDIA_ROOT = 'media/'

AWS_STORAGE_BUCKET_NAME = environ["bucket"]
AWS_QUERYSTRING_AUTH = False

AWS_S3_OBJECT_PARAMETERS = {
	'CacheControl': 'max-age=3600',
}


# Security
#---------------------------------------
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
LANGUAGE_COOKIE_SECURE = True


# Apps
#---------------------------------------
INSTALLED_APPS += [
	'storages',
]


# Disqus
#---------------------------------------
DISQUS_SHORTNAME = 'vazprojects'