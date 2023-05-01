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
STATIC_URL = f'https://{environ["staticFilesDomain"]}/'
MEDIA_URL = STATIC_URL


# Security
#---------------------------------------
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
LANGUAGE_COOKIE_SECURE = True


# Disqus
#---------------------------------------
DISQUS_SHORTNAME = 'vazprojects'