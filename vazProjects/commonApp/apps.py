#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.apps import AppConfig, apps
from django.db.models.signals import post_save, post_delete
from django.utils.translation import gettext_lazy as _

from .signals import clearCache



class commonAppConfig( AppConfig ):
	name = 'commonApp'
	verbose_name = _('Comum')
	
	def ready( self ):
		for Model in apps.get_models():
			post_save.connect( clearCache, sender = Model )
			post_delete.connect( clearCache, sender = Model )