#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import ListView, DetailView
from django.urls import reverse

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
		
		# Tags in the sidebar.
		context['allTags'] = TaggedItem.tags_for( BlogPost, blogpost__draft = False )
		
		# Pagination.
		if context['page_obj'].has_next():
			urlKwargs = { 'page': context['page_obj'].next_page_number(), **self.get_url_kwargs() }
			
			context['nextPageUrl'] = reverse( 'blogApp:blog', kwargs = urlKwargs )
		
		if context['page_obj'].has_previous():
			urlKwargs = { 'page': context['page_obj'].previous_page_number(), **self.get_url_kwargs() }
			
			context['previousPageUrl'] = reverse( 'blogApp:blog', kwargs = urlKwargs )
		
		return context
	
	def get_url_kwargs( self ):
		'''
		Return a dictionary with keyword arguments to reverse the paginator urls.
		'''
		
		return {}



class BlogByTag( Blog ):
	'''
	Blog view filtered by tag.
	'''
	
	allow_empty = False	# If we don't do this an invalid `tag_slug` will display an empty page.
	
	
	def get_queryset( self ):
		return super().get_queryset().filter( tags__slug = self.kwargs.get( 'tag_slug' ) )
	
	def get_url_kwargs( self ):
		'''
		Return a dictionary with keyword arguments to reverse the paginator urls.
		'''
		
		urlKwargs = super().get_url_kwargs()
		
		urlKwargs['tag_slug'] = self.kwargs.get( 'tag_slug' )
		
		return urlKwargs



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