# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.contrib import admin
from django.utils.translation import gettext_lazy as _

from commonApp.admin import UserImageInLine
from .models import BlogPost



@admin.register( BlogPost )
class BlogPostAdmin( admin.ModelAdmin ):
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
	
	
	def get_queryset( self, request ):
		return self.model.all_objects.get_queryset()
	
	
	# Object actions.
	@admin.action( description = _('Publish selected posts.') )
	def publish( self, request, queryset ):
		for post in queryset:
			post.publish()
		
		self.message_user( request, _('Published posts.'), level = 25 )
	
	
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
	actions = (
		'publish',
	)