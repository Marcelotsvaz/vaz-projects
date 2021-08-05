#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



class ServerCacheMiddleware:
	'''
	TODO: Private cache
	'''
	
	def __init__( self, getResponse ):
		self.getResponse = getResponse
	
	
	def __call__( self, request ):
		# Request stuff.
		
		
		# Get response.
		response = self.getResponse( request )
		
		# Response stuff.
		response['Cache-Control'] = 'no-cache'
		
		# Return.
		return response