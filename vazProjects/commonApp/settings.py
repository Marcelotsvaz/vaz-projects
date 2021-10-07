#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.conf import settings



MARKDOWN_FEATURES = getattr( settings, 'MARKDOWN_FEATURES', [
	# Block.
	'heading',
	'html_block',
	'list',
	
	# Inline.
	'emphasis',
	'html_inline',
	'image',
	'link',
	'newline',
])

MARKDOWN_OPTIONS = getattr( settings, 'MARKDOWN_FEATURES', {
	'breaks': True,
	'html': True,
})