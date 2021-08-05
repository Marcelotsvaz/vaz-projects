#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.conf import settings as appSettings



def settings( request ):
	return { 'settings': appSettings }