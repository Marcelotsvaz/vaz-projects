#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import TemplateView, ListView
from django.urls import reverse

from blogApp.search import BlogPostDocument



class Home( TemplateView ):
	'''
	Home view.
	'''
	
	template_name = 'siteApp/home.html'


class About_me( TemplateView ):
	'''
	About me view.
	'''
	
	template_name = 'siteApp/about_me.html'


class Search( ListView ):
	'''
	Site-wide search.
	'''
	
	paginate_by = 10
	template_name = 'siteApp/search.html'
	context_object_name = 'results'
	
	
	def get_queryset( self ):
		results = BlogPostDocument.search().query(
			'multi_match',
			query = self.kwargs['query'],
			fields = [ 'title', 'content' ],
			fuzziness = 2
		)
		
		return results
	
	def get_context_data( self, **kwargs ):
		context = super().get_context_data( **kwargs )
		
		# Pagination.
		if context['page_obj'].has_previous():
			urlKwargs = {
				'query': self.kwargs['query'],
				'page': context['page_obj'].previous_page_number(),
			}
						
			context['previousPageUrl'] = reverse( 'siteApp:search', kwargs = urlKwargs )
		
		if context['page_obj'].has_next():
			urlKwargs = {
				'query': self.kwargs['query'],
				'page': context['page_obj'].next_page_number(),
			}
			
			context['nextPageUrl'] = reverse( 'siteApp:search', kwargs = urlKwargs )
		
		return context


class Sitemap( TemplateView ):
	'''
	sitemap.xml.
	'''
	
	template_name = 'siteApp/sitemap.xml'
	content_type = 'text/xml'
	
	
	def get_context_data( self, **kwargs ):
		context = super().get_context_data( **kwargs )
		
		context['urls'] = []
		
		views = [
			'siteApp:home',
			'siteApp:about_me',
			'projectsApp:projects',
		]
		
		for view in views:
			context['urls'].append( self.request.build_absolute_uri( reverse( view ) ) )
		
		return context