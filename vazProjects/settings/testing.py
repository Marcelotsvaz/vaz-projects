#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .staging import *



# Static and media files
#---------------------------------------
STATICFILES_STORAGE = 'commonApp.backends.StaticOverwriteLocalStorage'
DEFAULT_FILE_STORAGE = 'commonApp.backends.OverwriteLocalStorage'