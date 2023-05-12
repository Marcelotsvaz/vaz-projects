# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from .staging import *



# General
#---------------------------------------
ENVIRONMENT = 'local'


# Static and media files
#---------------------------------------
STATIC_URL = f'{environ["staticFilesUrl"]}{AWS_STORAGE_BUCKET_NAME}/'
MEDIA_URL = STATIC_URL