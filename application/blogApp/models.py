# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.db import models
from django.db.models import (
	CharField, SlugField,
	BooleanField,
	DateTimeField, ImageField,
	ForeignKey,
)
from django.contrib.contenttypes.fields import GenericRelation
from django.contrib.auth import get_user_model
from django.urls import reverse
from django.conf import settings
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

from imagekit.models import ImageSpecField
from imagekit.processors import ResizeToFill

from taggit.managers import TaggableManager

from commonApp.fields import MarkdownField
from commonApp.models import getUploadFolder, UserImage
from commonApp.misc import getDisqusCommentCount



class BlogPostManager( models.Manager ):
	'''
	Filtered BlogPost manager.
	'''
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )



class BlogPost( models.Model ):
	'''
	Blog post.
	'''
	
	# Fields.
	slug				= SlugField(		_('slug'), max_length = 100, unique = True )
	title				= CharField(		_('title'), max_length = 100 )
	author				= ForeignKey(
		get_user_model(),
		on_delete = models.PROTECT,
		related_name = 'posts',
		verbose_name = _('author'),
	)
	banner_original		= ImageField(		_('banner'), upload_to = getUploadFolder( 'banner-original' ) )
	banner				= ImageSpecField(
		source = 'banner_original',
		processors = [ ResizeToFill( 1920, 750 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	thumbnail			= ImageSpecField(
		source = 'banner_original',
		processors = [ ResizeToFill( 1000, 350 ) ],
		format = 'JPEG',
		options = settings.IMAGE_OPTIONS['JPEG'],
	)
	content				= MarkdownField(	_('content') )
	user_images			= GenericRelation(	UserImage, for_concrete_model = False )
	draft				= BooleanField(		_('draft'), default = True )
	posted				= DateTimeField(	_('posted'), default = timezone.now )
	last_edited			= DateTimeField(	_('last edited'), auto_now = True  )
	
	tags				= TaggableManager(	_('tags'), blank = True )
	
	
	class Meta:
		verbose_name = _('post')
		verbose_name_plural = _('posts')
		ordering = ( '-posted', )
	
	
	# Manager.
	objects = BlogPostManager()
	
	
	# Methods.
	def __str__( self ):
		return self.title
	
	def get_absolute_url( self ):
		return reverse( 'blogApp:post', kwargs = { 'slug': self.slug } )
	
	def getMarkdownImages( self ):
		'''
		Return the images used in the Markdown fields.
		'''
		
		return self.user_images.all()
	
	@property
	def comment_count( self ):
		'''
		Get the number of comments in the thread associated with this post.
		'''
		
		return getDisqusCommentCount( self.get_absolute_url() )
	
	def publish( self ):
		'''
		Set `draft` to false and update `posted`, only if the post isn't already published.
		'''
		
		if self.draft == False:
			return
		
		self.draft = False
		self.posted = timezone.now()
		
		self.save()