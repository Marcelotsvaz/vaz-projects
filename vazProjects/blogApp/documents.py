#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django_elasticsearch_dsl import Document, fields
from django_elasticsearch_dsl.registries import registry

from .models import BlogPost



@registry.register_document
class BlogPostDocument( Document ):
	
	title = fields.TextField( attr = 'title' )
	content = fields.TextField( attr = 'render_content' )
	url = fields.TextField( attr = 'get_absolute_url' )
	
	
	class Index:
		name = 'blog'
	
	class Django:
		model = BlogPost
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )