#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .base import *
from .secrets import *



# General
########################################
ENVIRONMENT = 'development'


# Debug
########################################
DEBUG = True


# Static and media files
########################################
STATICFILES_STORAGE = 'commonApp.backends.StaticOverwriteLocalStorage'
DEFAULT_FILE_STORAGE = 'commonApp.backends.OverwriteLocalStorage'

STATIC_URL = '/static/'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'deployment/media'