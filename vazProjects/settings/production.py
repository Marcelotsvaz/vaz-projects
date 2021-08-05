#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .base import *
from .secrets import *



# General
########################################
ENVIRONMENT = 'production'


# Static and media files
########################################
STATICFILES_STORAGE = 'commonApp.backends.StaticCloudfrontStorage'
DEFAULT_FILE_STORAGE = 'commonApp.backends.CloudfrontStorage'

STATIC_URL = 'https://static-files.vazprojects.com/'
STATIC_ROOT = 'production/static/'

MEDIA_URL = 'https://static-files.vazprojects.com/'
MEDIA_ROOT = 'production/media/'

AWS_STORAGE_BUCKET_NAME = 'vaz-projects'
AWS_QUERYSTRING_AUTH = False

AWS_S3_OBJECT_PARAMETERS = {
	'CacheControl': 'max-age=3600',
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
CACHES = {
	'default':
	{
		'BACKEND': 'django.core.cache.backends.memcached.PyLibMCCache',
		'TIMEOUT': 365 * 24 * 60 * 60,	# 1 year.
		'LOCATION': '[::1]:11211',
	},
}
CACHE_MIDDLEWARE_SECONDS = CACHES['default']['TIMEOUT']