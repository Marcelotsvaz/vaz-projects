# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import re
from io import BufferedReader

from django.core.exceptions import SuspiciousFileOperation
from django.conf import settings

from storages.backends.s3boto3 import S3Boto3Storage



# Storage backends
#-------------------------------------------------------------------------------
class OverwriteStorageMixin():
	'''
	Mixin that overrides the get_available_name method so that it deletes the
	existing file and returns the same name.
	'''
	# TODO: Is this still necessary?
	def get_available_name( self, name, max_length = None ):
		if max_length and len( name ) > max_length:
			raise SuspiciousFileOperation(
				f'Storage can not find an available filename for "{name}".'
				' Please make sure that the corresponding file field'
				' allows sufficient "max_length".'
			)
		
		# Ideally this would be done in _save but to avoid race conditions between get_available_name and
		# _save Django's FileSystemStorage will keep calling get_available_name if the file already exists
		# after we delete it and we'll be stuck in an infinite loop, so we delete the file here.
		if self.exists( name ):
			self.delete( name )
		
		return name


class StaticStorageMixin():
	'''
	Mixin to replicate Django's StaticFilesStorage behaviour with different
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
		CloudfrontStorage copies the behaviour of Django's FileSystemStorage.
		'''
		
		if location is None:
			location = settings.MEDIA_ROOT
		
		if base_url is None:
			base_url = settings.MEDIA_URL
		
		# MEDIA_URL needs a protocol and to end with a slash, custom_domain must not.
		base_url = re.sub( r'^https?://(.*)/', r'\1', base_url )
		
		super().__init__( location = location, custom_domain = base_url, **kwargs )
		
	
	def url( self, name, parameters = None, expire = None, http_method = None ):
		'''
		Remove AWS_LOCATION from url.
		'''
		
		url = super().url( name, parameters, expire, http_method )
		
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