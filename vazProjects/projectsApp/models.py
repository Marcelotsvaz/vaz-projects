#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from pathlib import PurePath

from django.db import models
from django.db.models import CharField, SlugField
from django.db.models import BooleanField
# from django.db.models import DateField, DateTimeField, URLField, ImageField
# from django.db.models import ForeignKey
from django.urls import reverse
# from django.conf import settings
from django.utils.translation import gettext_lazy as _

# from imagekit.models import ImageSpecField
# from imagekit.processors import ResizeToFill, ResizeToFit

from commonApp.fields import TextField
# from commonApp.models import getUploadFolder



class Project( models.Model ):
	'''
	Project.
	'''
	
	class Meta:
		verbose_name = _('project')
		# ordering = ( 'category', 'name' )
	
	
	# Basic description fields.
	slug				= SlugField(		_('slug'), max_length = 100, unique = True )
	name				= CharField(		_('name'), max_length = 100 )
	# category			= ForeignKey(
	# 	Category,
	# 	on_delete = models.PROTECT,
	# 	related_name = 'packages',
	# 	verbose_name = _('categoria')
	# )
	# banner_original		= ImageField(		_('banner'), blank = True, upload_to = getUploadFolder( 'banner-original' ) )
	# thumbnail_original	= ImageField(		_('thumbnail'), blank = True, upload_to = getUploadFolder( 'thumbnail-original' ) )
	# banner				= ImageSpecField(
	# 	source = 'banner_original',
	# 	processors = [ ResizeToFill( 2000, 750 ) ],
	# 	format = 'JPEG',
	# 	options = settings.IMAGE_OPTIONS['JPEG'],
	# )
	# thumbnail			= ImageSpecField(
	# 	source = 'thumbnail_original',
	# 	processors = [ ResizeToFill( 300, 300 ) ],
	# 	format = 'JPEG',
	# 	options = settings.IMAGE_OPTIONS['JPEG'],
	# )
	short_description	= TextField(		_('short description') )
	# notes				= TextField(		_('notes'), blank = True )
	published			= BooleanField(		_('published'), default = False )
	# highlight			= BooleanField(		_('highlight') )
	
	
	# Detailed description fields.
	description			= TextField(		_('description'), blank = True )
	
	
	# Methods.
	def __str__( self ):
		return self.name
	
	def get_absolute_url( self ):
		return reverse( 'projectsApp:project', kwargs = { 'project_slug': self.slug } )