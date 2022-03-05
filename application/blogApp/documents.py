# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.utils.translation import gettext_lazy as _

from django_elasticsearch_dsl import Document, fields
from django_elasticsearch_dsl.registries import registry

from .models import BlogPost



@registry.register_document
class BlogPostDocument( Document ):
	
	title		= fields.TextField( attr = 'title' )
	content		= fields.TextField( attr = 'render_content' )
	url			= fields.TextField( attr = 'get_absolute_url', index = False )
	
	
	class Index:
		name = 'blog'
	
	class Django:
		model = BlogPost
	
	
	@property
	def resultTitle( self ):
		return self.title
	
	@property
	def resultLocation( self ):
		return _('found in blog')
	
	@property
	def resultUrl( self ):
		return self.url
	
	@property
	def resultDescription( self ):
		return self.content