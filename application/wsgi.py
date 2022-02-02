#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.core.wsgi import get_wsgi_application
from django.conf import settings



if settings.ENVIRONMENT == 'staging':
	import ptvsd
	ptvsd.enable_attach( address = ( '127.0.0.1', 3000 ) )

application = get_wsgi_application()