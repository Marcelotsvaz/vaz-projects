#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .base import *
from .secrets import *



# General
#---------------------------------------
ENVIRONMENT = 'development'


# Debug
#---------------------------------------
DEBUG = True
DEBUG_TOOLBAR_CONFIG = {
	'SHOW_TOOLBAR_CALLBACK': 'commonApp.misc.showDebugToolbar',
}


# Static and media files
#---------------------------------------
STATICFILES_STORAGE = 'commonApp.backends.StaticOverwriteLocalStorage'
DEFAULT_FILE_STORAGE = 'commonApp.backends.OverwriteLocalStorage'

STATIC_URL = '/static/'
STATIC_ROOT = 'deployment/collectedStatic'
STATICFILES_DIRS = [
	BASE_DIR / 'deployment/static/',	# Less files are compiled into this folder.
]

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'deployment/media/'
TESTS_MEDIA_ROOT = MEDIA_ROOT / 'tests/'


# Apps
#---------------------------------------
INSTALLED_APPS += [
	'debug_toolbar',
]


# Middleware
#---------------------------------------
# Put the debug toolbar middleware as high up as possible, but not before the CompressionMiddleware.
for index, item in enumerate( MIDDLEWARE ):
	if item == 'compression_middleware.middleware.CompressionMiddleware':
		MIDDLEWARE.insert( index + 1, 'debug_toolbar.middleware.DebugToolbarMiddleware' )
		break
else:
	MIDDLEWARE.insert( 0, 'debug_toolbar.middleware.DebugToolbarMiddleware' )


# Cache
#---------------------------------------
CACHES = {
	'default':
	{
		'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
		'TIMEOUT': 1,
	},
}
CACHE_MIDDLEWARE_SECONDS = CACHES['default']['TIMEOUT']