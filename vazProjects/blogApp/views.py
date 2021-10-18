#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import ListView, DetailView

from taggit.models import TaggedItem

from .models import BlogPost



class Blog( ListView ):
	'''
	Blog view.
	'''
	
	model = BlogPost
	paginate_by = 10
	template_name = 'blogApp/blog.html'
	context_object_name = 'posts'
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )
	
	def get_context_data( self, **kwargs ):
		context = super().get_context_data( **kwargs )
		
		context['tags'] = TaggedItem.tags_for( BlogPost, blogpost__draft = False )
		
		return context


class Post( DetailView ):
	'''
	Blog Post view.
	'''
	
	model = BlogPost
	template_name = 'blogApp/post.html'
	context_object_name = 'post'
	
	
	def get_queryset( self ):
		if self.request.user.is_staff:
			return super().get_queryset().all()
		else:
			return super().get_queryset().filter( draft = False )