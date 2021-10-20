#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django_elasticsearch_dsl import Document, fields
from django_elasticsearch_dsl.registries import registry

from .models import Project, Page



@registry.register_document
class ProjectDocument( Document ):
	
	title = fields.TextField( attr = 'name' )
	content = fields.TextField( attr = 'render_content' )
	url = fields.TextField( attr = 'get_absolute_url' )
	
	
	class Index:
		name = 'project'
	
	class Django:
		model = Project
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )


@registry.register_document
class PageDocument( Document ):
	
	title = fields.TextField( attr = 'name' )
	content = fields.TextField( attr = 'render_content' )
	url = fields.TextField( attr = 'get_absolute_url' )
	
	
	class Index:
		name = 'page'
	
	class Django:
		model = Page
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )