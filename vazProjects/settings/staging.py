#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .production import *



# General
########################################
ENVIRONMENT = 'staging'


# Debug
########################################
DEBUG = True


# Static and media files
########################################
STATIC_URL = 'https://static-files.staging.vazprojects.com/'
STATIC_ROOT = 'staging/static/'

MEDIA_URL = 'https://static-files.staging.vazprojects.com/'
MEDIA_ROOT = 'staging/media/'