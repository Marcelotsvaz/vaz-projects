#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.contrib import admin
from django_object_actions import DjangoObjectActions
from django.utils.translation import gettext_lazy as _

from commonApp.admin import UserImageInLine
from .models import BlogPost



@admin.register( BlogPost )
class BlogPostAdmin( DjangoObjectActions, admin.ModelAdmin ):
	'''
	Blog Post admin page.
	'''
	
	# List display options.
	list_display = (
		'title',
		'author',
		'posted',
		'draft',
	)
	list_display_links = ( 'title', )
	list_filter = (
		'posted',
		'draft',
	)
	
	
	# Fieldsets.
	main = {
		'fields': (
			( 'title', 'slug' ),
			'author',
			'banner_original',
			'content',
			'draft',
			'posted',
			'last_edited',
			'tags',
		)
	}
	
	
	# Object actions.
	def publish( self, request, object ):
		object.publish()
		
		self.message_user( request, _('Published post.'), level = 25 )
	
	publish.label = _('Publish')
	publish.short_description = _('Publish this post.')
	
	
	# Edit page options.
	fieldsets = (
		( _('Post'), main ),
	)
	prepopulated_fields = { 'slug': ( 'title', ) }
	readonly_fields = (
		'draft',
		'posted', 
		'last_edited', 
	)
	inlines = [ UserImageInLine ]
	change_actions = (
		'publish',
	)