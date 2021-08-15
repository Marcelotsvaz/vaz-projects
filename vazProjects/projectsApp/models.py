#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from pathlib import PurePath

from django.db import models
from django.db.models import (
	CharField, SlugField,
	IntegerField, PositiveIntegerField, BooleanField,
	DateTimeField, ImageField,
	ForeignKey,
	UniqueConstraint,
	Max,
)
from django.urls import reverse
from django.conf import settings
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill

from commonApp.fields import TextField, MarkdownField
from commonApp.models import getUploadFolder



class Category( models.Model ):
	'''
	Project category.
	'''
	
	# Fields.
	slug	= SlugField(	_('slug'), max_length = 100, unique = True )
	name	= CharField(	_('name'), max_length = 100 )
	order	= IntegerField(	_('order'), default = 0 )
	
	
	class Meta:
		verbose_name = _('category')
		verbose_name_plural = _('categories')
		ordering = ( 'order', 'name' )
	
	
	# Methods.
	def __str__( self ):
		return self.name



class Project( models.Model ):
	'''
	Project.
	'''
	
	# Fields.
	slug				= SlugField(		_('slug'), max_length = 100, unique = True )
	name				= CharField(		_('name'), max_length = 100 )
	category			= ForeignKey(
		Category,
		on_delete = models.PROTECT,
		related_name = 'projects',
		verbose_name = _('category'),
	)
	banner_original		= ImageField(		_('banner'), upload_to = getUploadFolder( 'banner-original' ) )
	banner				= ImageSpecField(
		source = 'banner_original',
		processors = [ ResizeToFill( 2000, 750 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	thumbnail_original	= ImageField(		_('thumbnail'), upload_to = getUploadFolder( 'thumbnail-original' ) )
	thumbnail			= ImageSpecField(
		source = 'thumbnail_original',
		processors = [ ResizeToFill( 300, 300 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	description			= TextField(		_('description') )
	content				= MarkdownField(	_('content') )
	single_page			= BooleanField(		_('single page'), default = False )
	draft				= BooleanField(		_('draft'), default = True )
	highlight			= BooleanField(		_('highlight'), default = False )
	posted				= DateTimeField(	_('posted'), default = timezone.now )
	base_last_edited	= DateTimeField(	_('base last edited'), default = timezone.now )
	notes				= TextField(		_('notes'), blank = True )
	
	
	class Meta:
		verbose_name = _('project')
		verbose_name_plural = _('projects')
		ordering = ( 'category', 'name' )
	
	
	# Methods.
	def __str__( self ):
		return self.name
	
	def get_absolute_url( self ):
		return reverse( 'projectsApp:project', kwargs = { 'project_slug': self.slug } )
	
	@property
	def last_edited( self ):
		if self.single_page:
			return self.base_last_edited
		else:
			return max( self.base_last_edited, self.pages.aggregate( last_edited = Max( 'last_edited' ) )['last_edited'] )



class Page( models.Model ):
	'''
	Project page.
	'''
	
	# Fields.
	project				= ForeignKey(
		Project,
		on_delete = models.CASCADE,
		related_name = 'pages',
		verbose_name = _('project')
	)
	number				= PositiveIntegerField(	_('page number') )
	type				= CharField(			_('type'), max_length = 100, blank = True )
	name				= CharField(			_('name'), max_length = 100 )
	banner_original		= ImageField(			_('banner'), upload_to = getUploadFolder( 'banner-original' ) )
	banner				= ImageSpecField(
		source = 'banner_original',
		processors = [ ResizeToFill( 2000, 750 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	thumbnail_original	= ImageField(			_('thumbnail'), upload_to = getUploadFolder( 'thumbnail-original' ) )
	thumbnail			= ImageSpecField(
		source = 'thumbnail_original',
		processors = [ ResizeToFill( 300, 300 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	description			= TextField(			_('description') )
	content				= MarkdownField(		_('content') )
	draft				= BooleanField(			_('draft'), default = True )
	posted				= DateTimeField(		_('posted'), default = timezone.now )
	last_edited			= DateTimeField(		_('last edited'), default = timezone.now )
	
	
	class Meta:
		verbose_name = _('project page')
		verbose_name_plural = _('project pages')
		ordering = ( 'project', 'number' )
		
		constraints = [
			UniqueConstraint( fields = [ 'project', 'number' ], name = 'uniqueForProject' ),
		]
	
	
	# Methods.
	def __str__( self ):
		return f'<{self.project}> {self.full_name}'
	
	def get_absolute_url( self ):
		return reverse( 'projectsApp:project', kwargs = { 'project_slug': self.project.slug, 'page_number': self.number } )
	
	@property
	def full_name( self ):
		return ( self.type or _('Part {0}: {1}') ).format( self.number, self.name )
	
	# def publish( self ):
	# 	self.draft = False
	# 	self.posted = timezone.now()
	# 	self.save()