# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import re
from io import BufferedReader

from django.conf import settings

from storages.backends.s3boto3 import S3Boto3Storage



# Storage backends
#-------------------------------------------------------------------------------
class StaticStorageMixin():
	'''
	Mixin to replicate Django's StaticFilesStorage behavior with different
	base storage backends.
	'''
	
	def __init__( self, location = None, base_url = None, *args, **kwargs ):
		if location is None:
			location = settings.STATIC_ROOT
		
		if base_url is None:
			base_url = settings.STATIC_URL
		
		super().__init__( location, base_url, *args, **kwargs )



class NonCloseableBufferedReader( BufferedReader ):
	def close( self ):
		self.flush()


class CloudfrontStorage( S3Boto3Storage ):
	'''
	Storage backend based on S3Boto3Storage with support for CloudFront's
	"Origin Path" setting.
	'''
	
	def __init__( self, location = None, base_url = None, **kwargs ):
		'''
		CloudfrontStorage copies the behavior of Django's FileSystemStorage.
		'''
		
		if location is None:
			location = settings.MEDIA_ROOT
		
		if base_url is None:
			base_url = settings.MEDIA_URL
		
		# MEDIA_URL needs a protocol and to end with a slash, custom_domain must not.
		base_url = re.sub( r'^https?://(.+)/', r'\1', base_url )
		
		super().__init__( location = location, custom_domain = base_url, **kwargs )
		
	
	def url( self, name, parameters = None, expire = None, http_method = None ):
		'''
		Remove AWS_LOCATION from url.
		'''
		
		url = super().url( name or '', parameters, expire, http_method )
		
		return re.sub( fr'(://[\w\-.]+/){self.location}/?', r'\1', url )
	
	
	def _save( self, name, content ):
		'''
		Pass a copy of content to Boto so it won't close the original.
		Workaround for https://github.com/matthewwithanm/django-imagekit/issues/391.
		'''
		
		with NonCloseableBufferedReader( content ) as buffer:
			return super()._save( name, buffer )


class StaticCloudfrontStorage( StaticStorageMixin, CloudfrontStorage ):
	pass