#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import ListView, DetailView

from .models import BlogPost



class Blog( ListView ):
	'''
	Blog view.
	'''
	
	model = BlogPost
	template_name = 'blogApp/blog.html'
	context_object_name = 'posts'
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( draft = False )


class Post( DetailView ):
	'''
	Blog Post view.
	'''
	
	model = BlogPost
	template_name = 'blogApp/post.html'
	context_object_name = 'post'
	
	
	def get_queryset(self):
		return super().get_queryset().filter( draft = False )