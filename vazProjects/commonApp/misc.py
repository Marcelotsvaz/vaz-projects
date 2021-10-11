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
def getDisqusCommentCount( identifier, refresh = False ):
	'''
	Return the post count for a Disqus thread by `identifier`. Results are cached.
	'''
	
	cacheKey = f'getDisqusCommentCount:{identifier}'
	commentCount = cache.get( cacheKey )
	
	if commentCount is None or refresh:
		url = 'https://disqus.com/api/3.0/threads/list.json'
		parameters = {
			'api_key': settings.DISQUS_API_KEY,
			'forum': settings.DISQUS_SHORTNAME,
			'thread': 'ident:' + identifier,
		}
		
		request = requests.get( url, params = parameters )
		
		if request.status_code != 200:
			return 0
		
		commentCount = request.json()['response'][0]['posts']
		cache.set( cacheKey, commentCount )
	
	return commentCount