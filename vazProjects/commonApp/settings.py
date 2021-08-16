#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.conf import settings



MARKDOWN_FEATURES = getattr( settings, 'MARKDOWN_FEATURES', [
	'heading',
	'list',
	'emphasis',
	'newline',
	'link',
])