# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.contrib import admin
from jet.admin import CompactInline
from django.utils.translation import gettext_lazy as _

from commonApp.admin import UserImageInLine
from .models import Category, Project, Page



@admin.register( Category )
class CategoryAdmin( admin.ModelAdmin ):
	'''
	Category admin page.
	'''
	
	# List display options.
	list_display = (
		'name',
	)
	
	
	# Fieldsets.
	main = {
		'fields': (
			( 'name', 'slug' ),
			'order',
		)
	}
	
	
	# Edit page options.
	fieldsets = (
		( None, main ),
	)
	prepopulated_fields = { 'slug': ( 'name', ) }



class PageInLine( CompactInline ):
	'''
	Page inline.
	'''
	
	model = Page
	extra = 0
	
	
	# Fieldsets.
	main = {
		'fields': (
			( 'number', 'type' ),
			'name',
			'content',
		)
	}
	
	metadata = {
		'fields': (
			'banner_original',
			'thumbnail_original',
			'description',
			'draft',
			'posted',
			'last_edited',
		)
	}
	
	
	def get_queryset( self, request ):
		return self.model.all_objects.get_queryset()
	
	
	# Edit page options.
	fieldsets = (
		( None, main ),
		( _('Metadata'), metadata ),
	)
	readonly_fields = (
		'draft',
		'posted',
		'last_edited',
	)



@admin.register( Project )
class ProjectAdmin( admin.ModelAdmin ):
	'''
	Project admin page.
	'''
	
	# List display options.
	list_display = (
		'category',
		'name',
		'author',
		'draft',
		'highlight',
	)
	list_display_links = ( 'name', )
	list_filter = (
		'category',
		'draft',
		'highlight',
	)
	
	
	# Fieldsets.
	main = {
		'fields': (
			( 'name', 'slug' ),
			'author',
			'category',
			'banner_original',
			'thumbnail_original',
			'description',
			'content',
			'draft',
			'highlight',
			'posted',
			'base_last_edited',
			'notes',
		)
	}
	
	
	def get_queryset( self, request ):
		return self.model.all_objects.get_queryset()
	
	
	# Object actions.
	@admin.action( description = _('Publish selected projects.') )
	def publish( self, request, queryset ):
		for project in queryset:
			project.publish()
		
		self.message_user( request, _('Published projects.'), level = 25 )
	
	@admin.action( description = _('Publish selected projects and its pages.') )
	def publishAll( self, request, queryset ):
		for project in queryset:
			project.publish( publishPages = True )
		
		self.message_user( request, _('Published projects and pages.'), level = 25 )
	
	
	# Edit page options.
	fieldsets = (
		( _('Project'), main ),
	)
	prepopulated_fields = { 'slug': ( 'name', ) }
	readonly_fields = (
		'draft',
		'posted',
		'base_last_edited',
	)
	inlines = [ PageInLine, UserImageInLine ]
	actions = (
		'publish',
		'publishAll',
	)