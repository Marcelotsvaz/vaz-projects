#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .production import *



# General
#---------------------------------------
ENVIRONMENT = 'staging'


# Debug
#---------------------------------------
DEBUG = True
DEBUG_TOOLBAR_CONFIG = {
	'SHOW_TOOLBAR_CALLBACK': 'commonApp.misc.showDebugToolbar',
}


# Static and media files
#---------------------------------------
STATIC_URL = 'https://static-files.staging.vazprojects.com/'
STATIC_ROOT = 'staging/static/'
STATICFILES_DIRS = [
	BASE_DIR / 'deployment/static/',	# Less files are compiled into this folder.
]

MEDIA_URL = 'https://static-files.staging.vazprojects.com/'
MEDIA_ROOT = 'staging/media/'


# Apps
#---------------------------------------
INSTALLED_APPS += [
	'debug_toolbar',
]


# Middleware
#---------------------------------------
# Put the debug toolbar middleware as high up as possible, but not before the CompressionMiddleware.
for index, item in enumerate( MIDDLEWARE ):
	# if item == 'compression_middleware.middleware.CompressionMiddleware':
	if item == 'django.middleware.cache.UpdateCacheMiddleware':	# TODO: Workaround until Django Debug Toolbar supports brotli.
		MIDDLEWARE.insert( index + 1, 'debug_toolbar.middleware.DebugToolbarMiddleware' )
		break
else:
	MIDDLEWARE.insert( 0, 'debug_toolbar.middleware.DebugToolbarMiddleware' )


# Cache
#---------------------------------------
CACHES['default']['TIMEOUT'] = 60
CACHE_MIDDLEWARE_SECONDS = CACHES['default']['TIMEOUT']


# Disqus
#---------------------------------------
DISQUS_SHORTNAME = 'staging-vazprojects'