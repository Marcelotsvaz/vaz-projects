# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.db import models
from django.db.models import (
	CharField, SlugField,
	IntegerField, PositiveIntegerField, BooleanField,
	DateTimeField, ImageField,
	ForeignKey,
	UniqueConstraint,
	Max,
)
from django.contrib.contenttypes.fields import GenericRelation
from django.contrib.auth import get_user_model
from django.urls import reverse
from django.conf import settings
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill

from commonApp.fields import TextField, MarkdownField
from commonApp.models import getUploadFolder, UserImage
from commonApp.misc import getDisqusCommentCount



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



class ProjectManager( models.Manager ):
	'''
	Filtered Project manager.
	'''
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )



class Project( models.Model ):
	'''
	Project.
	'''
	
	# Fields.
	slug				= SlugField(		_('slug'), max_length = 100, unique = True )
	name				= CharField(		_('name'), max_length = 100 )
	author				= ForeignKey(
		get_user_model(),
		on_delete = models.PROTECT,
		related_name = 'projects',
		verbose_name = _('author'),
	)
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
	draft				= BooleanField(		_('draft'), default = True )
	highlight			= BooleanField(		_('highlight'), default = False )
	posted				= DateTimeField(	_('posted'), default = timezone.now )
	base_last_edited	= DateTimeField(	_('base last edited'), auto_now = True  )
	notes				= TextField(		_('notes'), blank = True )
	user_images			= GenericRelation(	UserImage, for_concrete_model = False )
	
	
	class Meta:
		verbose_name = _('project')
		verbose_name_plural = _('projects')
		ordering = ( 'category', 'name' )
	
	
	# Manager.
	objects = ProjectManager()
	all_objects = models.Manager()
	
	
	# Methods.
	def __str__( self ):
		return self.name
	
	def get_absolute_url( self ):
		return reverse( 'projectsApp:project', kwargs = { 'project_slug': self.slug } )
	
	@property
	def all_pages( self ):
		return self.pages( manager = 'all_objects' )
	
	@property
	def single_page( self ):
		return self.all_pages.count() == 0
	
	@property
	def last_edited( self ):
		# Will return None for single page projects or if all pages are drafts.
		pagesLastEdited = self.pages.aggregate( last_edited = Max( 'last_edited' ) )['last_edited']
		
		if pagesLastEdited is not None:
			return max( self.base_last_edited, pagesLastEdited )
		else:
			return self.base_last_edited
	
	@property
	def comment_count( self ):
		'''
		Get the number of comments in the threads associated with this post and all of its pages.
		'''
		
		pageCommentCount = sum( page.comment_count for page in self.pages.all() )
		
		return getDisqusCommentCount( self.get_absolute_url() ) + pageCommentCount
			
	def getMarkdownImages( self ):
		'''
		Return the images used in the Markdown fields.
		'''
		
		return self.user_images.all()
	
	def publish( self, publishPages = False ):
		'''
		Set `draft` to false and update `posted`, only if the project isn't already published.
		Optionally also publish unpublished pages.
		'''
		
		if publishPages:
			for page in self.all_pages.filter( draft = True ):
				page.publish()
		
		if self.draft == False:
			return
		
		self.draft = False
		self.posted = timezone.now()
		
		self.save()



class PageManager( models.Manager ):
	'''
	Filtered Project Page manager.
	'''
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )



class Page( models.Model ):
	'''
	Project page.
	'''
	
	# Fields.
	project				= ForeignKey(
		Project,
		on_delete = models.CASCADE,
		related_name = 'pages',
		verbose_name = _('project'),
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
	last_edited			= DateTimeField(		_('last edited'), auto_now = True )
	
	
	class Meta:
		verbose_name = _('project page')
		verbose_name_plural = _('project pages')
		ordering = ( 'project', 'number' )
		
		constraints = [
			UniqueConstraint( fields = [ 'project', 'number' ], name = 'uniqueForProject' ),
		]
	
	
	# Manager.
	objects = ProjectManager()
	all_objects = models.Manager()
	
	
	# Methods.
	def __str__( self ):
		return f'<{self.project}> {self.full_name}'
	
	def get_absolute_url( self ):
		return reverse( 'projectsApp:project', kwargs = { 'project_slug': self.project.slug, 'page_number': self.number } )
	
	@property
	def full_name( self ):
		'''
		Return the full name of the page, which includes its `type`, `number` and `name`.
		'''
		
		return ( self.type or _('Part {0}: {1}') ).format( self.number, self.name )
	
	@property
	def comment_count( self ):
		'''
		Get the number of comments in the thread associated with this page.
		'''
		
		return getDisqusCommentCount( self.get_absolute_url() )
	
	def getMarkdownImages( self ):
		'''
		Return the images used in the Markdown fields.
		'''
		
		return self.project.user_images.all()
	
	def publish( self ):
		'''
		Set `draft` to false and update `posted`, only if the page isn't already published.
		'''
		
		if self.draft == False:
			return
		
		self.draft = False
		self.posted = timezone.now()
		
		self.save()