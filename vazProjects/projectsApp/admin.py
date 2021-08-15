#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.contrib import admin
from jet.admin import CompactInline

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
	# readonly_fields = ( 'publishDate', )



@admin.register( Project )
class ProjectAdmin( admin.ModelAdmin ):
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
			'single_page',
			'draft',
			'highlight',
			'posted',
			'base_last_edited',
			'notes',
		)
	}
	
	
	# Edit page options.
	fieldsets = (
		( None, main ),
	)
	prepopulated_fields = { 'slug': ( 'name', ) }
	inlines = [ PageInLine ]