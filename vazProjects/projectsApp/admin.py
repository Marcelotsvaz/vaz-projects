#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.contrib import admin
from django.utils.translation import gettext_lazy as _

from .models import Project, Category



@admin.register( Category )
class CategoryAdmin( admin.ModelAdmin ):
	'''
	Category admin page.
	'''
	
	# List display options.
	list_display = ( 'name', )
	
	
	# Edit page options.
	prepopulated_fields = { 'slug': ( 'name', ) }



@admin.register( Project )
class ProjectAdmin( admin.ModelAdmin ):
	'''
	Project admin page.
	'''
	
	# List display options.
	list_display = (
		'category',
		'name',
		'highlight',
		'published',
	)
	list_display_links = ( 'name', )
	list_filter = ( 'category', 'highlight', 'published' )
	
	
	# Fieldsets.
	basicDescriptionFields = {
		'fields': (
			( 'name', 'slug' ),
			'category',
			'banner_original',
			'thumbnail_original',
			'short_description',
			'notes',
			'published',
			'highlight',
		)
	}
	
	detailedDescriptionFields = {
		'fields': (
			'description',
		)
	}
	
	
	# Edit page options.
	fieldsets = (
		( _('basic description'), basicDescriptionFields ),
		( _('detailed description'), detailedDescriptionFields ),
	)
	prepopulated_fields = { 'slug': ( 'name', ) }