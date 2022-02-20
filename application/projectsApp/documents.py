# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.utils.translation import gettext_lazy as _

from django_elasticsearch_dsl import Document, fields
from django_elasticsearch_dsl.registries import registry

from .models import Project, Page



@registry.register_document
class ProjectDocument( Document ):
	
	name		= fields.TextField( attr = 'name' )
	description	= fields.TextField( attr = 'description' )
	content		= fields.TextField( attr = 'render_content' )
	url			= fields.TextField( attr = 'get_absolute_url', index = False )
	
	
	class Index:
		name = 'project'
	
	class Django:
		model = Project
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )
	
	@property
	def resultTitle( self ):
		return self.name
	
	@property
	def resultLocation( self ):
		return _('found in projects')
	
	@property
	def resultUrl( self ):
		return self.url
	
	@property
	def resultDescription( self ):
		return self.description



@registry.register_document
class PageDocument( Document ):
	
	name			= fields.TextField( attr = 'name' )
	description		= fields.TextField( attr = 'description' )
	content			= fields.TextField( attr = 'render_content' )
	url				= fields.TextField( attr = 'get_absolute_url', index = False )
	
	project_name	= fields.TextField( attr = 'project.name', index = False )
	project_url		= fields.TextField( attr = 'project.get_absolute_url', index = False )
	
	
	class Index:
		name = 'page'
	
	class Django:
		model = Page
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )
	
	@property
	def resultTitle( self ):
		return self.name
	
	@property
	def resultLocation( self ):
		return _('found in project {}').format( f'<a href="{self.project_url}">{self.project_name}</a>' )
	
	@property
	def resultUrl( self ):
		return self.url
	
	@property
	def resultDescription( self ):
		return self.description