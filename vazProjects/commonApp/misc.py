#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



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