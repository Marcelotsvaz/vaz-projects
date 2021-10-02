#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.contrib import admin
from jet.admin import CompactInline
from django_object_actions import DjangoObjectActions
from django.utils.translation import gettext_lazy as _

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
		( 'Metadata', metadata ),
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
		'draft',
		'highlight',
	)
	list_display_links = ( 'name', )
	list_filter = ( 'category', 'draft', 'highlight' )
	
	
	# Fieldsets.
	main = {
		'fields': (
			( 'name', 'slug' ),
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
	publish.label = _('Publish')
	publish.short_description = _('Publish this project.')
	
	def publishAll( self, request, object ):
		object.publish( publishPages = True )
	publishAll.label = _('Publish All')
	publishAll.short_description = _('Publish this project and all of its pages.')
	
	
	# Edit page options.
	fieldsets = (
		( None, main ),
	)
	prepopulated_fields = { 'slug': ( 'name', ) }
	readonly_fields = (
		'draft',
		'posted', 
		'base_last_edited', 
	)
	inlines = [ PageInLine ]
	change_actions = ( 'publish', 'publishAll' )