#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.utils.translation import gettext, ngettext
from django.templatetags.static import static
from django.urls import reverse
from django.conf import settings
from datetime import datetime

from jinja2 import Environment



def environment( **options ):
	env = Environment( extensions = [ 'jinja2.ext.i18n' ], **options )
	
	env.install_gettext_callables( gettext, ngettext, newstyle = True )
	
	env.globals.update({
		'static': static,
		'url': reverse,
		'settings': settings,
		'datetime': datetime,
	})
	
	return env