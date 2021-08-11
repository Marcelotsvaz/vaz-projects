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
	
	class Meta:
		verbose_name = _('category')
		verbose_name_plural = _('categories')
		ordering = ( 'order', 'name' )
	
	
	# Fields.
	slug	= SlugField(	_('slug'), max_length = 100, unique = True )
	name	= CharField(	_('name'), max_length = 100 )
	order	= IntegerField(	_('order'), default = 0 )
	
	
	# Methods.
	def __str__( self ):
		return self.name



class Project( models.Model ):
	'''
	Project.
	'''
	
	class Meta:
		verbose_name = _('project')
		ordering = ( 'category', 'name' )
	
	
	# Basic description fields.
	slug				= SlugField(		_('slug'), max_length = 100, unique = True )
	name				= CharField(		_('name'), max_length = 100 )
	category			= ForeignKey(
		Category,
		on_delete = models.PROTECT,
		related_name = 'projects',
		verbose_name = _('category'),
	)
	banner_original		= ImageField(		_('banner'), upload_to = getUploadFolder( 'banner-original' ) )
	thumbnail_original	= ImageField(		_('thumbnail'), upload_to = getUploadFolder( 'thumbnail-original' ) )
	banner				= ImageSpecField(
		source = 'banner_original',
		processors = [ ResizeToFill( 2000, 750 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	thumbnail			= ImageSpecField(
		source = 'thumbnail_original',
		processors = [ ResizeToFill( 300, 300 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	short_description	= TextField(		_('short description') )
	notes				= TextField(		_('notes'), blank = True )
	published			= BooleanField(		_('published'), default = False )
	publishDate			= DateTimeField(	_('publish date'), default = timezone.now )
	singlePage			= BooleanField(		_('single page'), default = False )
	highlight			= BooleanField(		_('highlight'), default = False )
	
	
	# Detailed description fields.
	description			= TextField(		_('description') )
	
	
	# Methods.
	def __str__( self ):
		return self.name
	
	def get_absolute_url( self ):
		return reverse( 'projectsApp:project', kwargs = { 'project_slug': self.slug } )



class Page( models.Model ):
	'''
	Project page.
	'''
	
	class Meta:
		verbose_name = _('project page')
		ordering = ( 'page_number', 'project' )
		
		constraints = [
			UniqueConstraint( fields = [ 'page_number', 'project' ], name = 'uniqueForProject' ),
		]
	
	
	# Fields.
	project		= ForeignKey(
		Project, related_name = 'pages',
		on_delete = models.CASCADE,
		verbose_name = _('project')
	)
	page_number	= PositiveIntegerField(	_('page number') )
	type		= CharField(			_('type'), max_length = 100, blank = True )
	name		= CharField(			_('name'), max_length = 100 )
	description	= TextField(			_('description') )
	content		= MarkdownField(		_('content') )
	
	
	# Methods.
	def __str__( self ):
		return self.fullName()
	
	# def get_absolute_url( self ):
	# 	return reverse( 'siteApp:package', kwargs = { 'package_slug': self.slug } )	# TODO: Use package URL with hashbang.
	
	def publish( self ):
		self.draft = False
		self.publishDate = timezone.now()
		self.save()
	
	def fullName( self ):
		return ( self.type or 'Part {0}: {1}' ).format( self.number, self.name )