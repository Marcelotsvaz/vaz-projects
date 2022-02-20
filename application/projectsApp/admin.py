# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.contrib import admin
from jet.admin import CompactInline
from django_object_actions import DjangoObjectActions
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
class ProjectAdmin( DjangoObjectActions, admin.ModelAdmin ):
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
	
	
	# Object actions.
	def publish( self, request, object ):
		object.publish()
		
		self.message_user( request, _('Published project.'), level = 25 )
	
	publish.label = _('Publish')
	publish.short_description = _('Publish this project.')
	
	def publishAll( self, request, object ):
		object.publish( publishPages = True )
		
		self.message_user( request, _('Published project and pages.'), level = 25 )
	
	publishAll.label = _('Publish All')
	publishAll.short_description = _('Publish this project and all of its pages.')
	
	
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
	change_actions = (
		'publish',
		'publishAll',
	)