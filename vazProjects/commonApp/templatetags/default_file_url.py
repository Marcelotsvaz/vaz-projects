#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django import template



register = template.Library()



@register.filter( name='default_file_url' )
def default_file_url( file, defaultUrl ):
	'''
	Exchange rate.
	'''
	
	if file:
		return file.url
	else:
		return defaultUrl