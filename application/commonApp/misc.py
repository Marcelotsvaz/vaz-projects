# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import requests

from django.core.cache import cache
from django.conf import settings



# django-imagekit
#-------------------------------------------------------------------------------
class Optimistic():
	'''
	A strategy that acts immediately when the source file changes, generating
	the file even if it already exists in storage and assumes that the cache
	files will not be removed (i.e. it doesn't ensure the cache file exists when
	it's accessed).
	'''
	
	def on_source_saved( self, file ):
		file.generate( force = True )

	def should_verify_existence( self, file ):
		return False



# django-debug-toolbar
#-------------------------------------------------------------------------------
def showDebugToolbar( request ):
	'''
	Callback used by django-debug-toolbar.
	'''
	
	return settings.DEBUG



# Disqus
#-------------------------------------------------------------------------------
def getDisqusCommentsCount( identifiers, refresh = False ):
	'''
	Return the post count for a list of Disqus threads from the cache or updated from the Disqus API.
	'''
	
	cacheKeyPrefix = 'getDisqusCommentsCount:'
	commentsCount = { identifier: cache.get( cacheKeyPrefix + identifier ) or 0 for identifier in identifiers }
	
	if not refresh:
		return commentsCount
	
	url = 'https://disqus.com/api/3.0/threads/list.json'
	parameters = {
		'api_key': settings.DISQUS_API_PUBLIC_KEY,
		'forum': settings.DISQUS_SHORTNAME,
		'thread': ( 'ident:' + identifier for identifier in identifiers ),
	}
	request = requests.get( url, params = parameters )
	
	if request.status_code != 200:
		try:
			errorMessage = request.json()['response']
		except requests.exceptions.JSONDecodeError as error:
			raise Exception( f'Disqus API answered with status code {request.status_code} and no error message.' ) from error
		
		raise Exception( f'Disqus API error: {errorMessage}.' )
	
	updatedCommentsCount = { thread['identifiers'][0]: thread['posts'] for thread in request.json()['response'] }
	
	for identifier in identifiers:
		count = updatedCommentsCount.get( identifier, 0 )
		
		cache.set( cacheKeyPrefix + identifier, count )
		commentsCount[identifier] = count
	
	return commentsCount