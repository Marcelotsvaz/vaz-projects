#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from pathlib import PurePath

from django.db import models
from django.db.models import CharField, SlugField
from django.db.models import PositiveIntegerField
from django.db.models import ImageField
from django.db.models import ForeignKey
from django.db.models import UniqueConstraint
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from django.utils.deconstruct import deconstructible

from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFit



@deconstructible
class getUploadFolder():
	'''
	Generate a path for a django FileField where the stem is based on the original filename, an fixed value,
	an instance's method or a formated string.
	The path is an fixed value or the result of the instance's get_absolute_url method.
	
	Example for getUploadFolder( 'banner' ):
	stem = banner
	originalFilename = 'IMG_E0182.JPG'
	package.get_absolute_url() = '/pacotes/turquia-premium'
	
	Returns pacotes/turquia-premium/banner.jpg
	'''
	
	def __init__( self, stem = None, method = None, useUrl = True ):
		self.method = method
		self.stem = stem
		self.useUrl = useUrl
	
	def __call__( self, instance, originalFilename ):
		if self.stem and self.method:
			stem = self.stem.format( getattr( instance, self.method ) )
		elif self.stem:
			stem = self.stem
		elif self.method:
			stem = getattr( instance, self.method )
		else:
			stem = PurePath( originalFilename ).stem.lower()
		
		filename = stem + PurePath( originalFilename ).suffix.lower()
		
		if self.useUrl:
			return PurePath( instance.get_absolute_url().lstrip( '/' ) ) / filename
		else:
			return PurePath( filename )



class UserImage( models.Model ):
	'''
	User managed image.
	'''
	
	class Meta:
		verbose_name = _('user image')
		verbose_name_plural = _('user images')
		
		constraints = [
			UniqueConstraint( fields = [ 'identifier', 'content_type', 'object_id' ], name = 'uniqueForObject' ),
		]
	
	
	# Fields.
	content_type	= ForeignKey( ContentType, on_delete = models.CASCADE )
	object_id		= PositiveIntegerField()
	content_object	= GenericForeignKey( for_concrete_model = False )
	
	identifier		= SlugField(	_('identifier'), max_length = 100 )
	alt				= CharField(	_('description'), max_length = 250, blank = True )
	attribution		= CharField(	_('attribution'), max_length = 250, blank = True )
	notes			= CharField(	_('notes'), max_length = 250, blank = True )
	image_original	= ImageField(	_('image'), upload_to = getUploadFolder( '{}-original', method = 'identifier' ) )
	image_small		= ImageSpecField(
		source = 'image_original',
		processors = [ ResizeToFit( 250 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	image_large		= ImageSpecField(
		source = 'image_original',
		processors = [ ResizeToFit( 1000 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	
	
	# Methods.
	def get_absolute_url( self ):
		return self.content_object.get_absolute_url()