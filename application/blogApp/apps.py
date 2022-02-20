# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _



class blogAppConfig( AppConfig ):
	name = 'blogApp'
	verbose_name = _('blog')