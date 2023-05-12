# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .base import *



# General
#---------------------------------------
ENVIRONMENT = 'production'


# Static and media files
#---------------------------------------
STATIC_URL = environ["staticFilesUrl"]
MEDIA_URL = STATIC_URL


# Disqus
#---------------------------------------
DISQUS_SHORTNAME = 'vazprojects'