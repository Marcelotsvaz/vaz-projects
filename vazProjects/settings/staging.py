#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .base import *
from .secrets import *



# General
########################################
ENVIRONMENT = 'staging'


# Debug
########################################
DEBUG = True


# Static and media files
########################################
STATICFILES_STORAGE = 'commonApp.backends.StaticCloudfrontStorage'
DEFAULT_FILE_STORAGE = 'commonApp.backends.CloudfrontStorage'

STATIC_URL = 'https://static-files.staging.vazprojects.com/'
STATIC_ROOT = 'staging/static/'

MEDIA_URL = 'https://static-files.staging.vazprojects.com/'
MEDIA_ROOT = 'staging/media/'

AWS_STORAGE_BUCKET_NAME = 'vaz-projects'
AWS_QUERYSTRING_AUTH = False

AWS_S3_OBJECT_PARAMETERS = {
	'CacheControl': 'max-age=60',
}


# Security
########################################
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
LANGUAGE_COOKIE_SECURE = True


# Apps
########################################
INSTALLED_APPS += [
	'storages',
]


# Cache
########################################
CACHES['default']['BACKEND'] = 'django.core.cache.backends.memcached.PyLibMCCache'
CACHES['default']['LOCATION'] = '[::1]:11211'