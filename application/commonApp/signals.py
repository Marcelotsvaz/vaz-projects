# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.core.cache import cache



def clearCache( **kwargs ):
	'''
	Clear the default cache after any model is saved or deleted.
	'''
	
	cache.clear()