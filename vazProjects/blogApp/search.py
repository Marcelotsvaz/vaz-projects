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
	
	content = fields.TextField( attr = 'render_content' )
	
	
	class Index:
		name = 'blog'
	
	class Django:
		model = BlogPost
		fields = [
			'title',
		]
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )