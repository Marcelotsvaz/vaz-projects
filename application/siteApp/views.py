# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import TemplateView, ListView
from django.urls import reverse
from django.utils.http import urlencode

from django_elasticsearch_dsl.search import Search as DslSearch

from blogApp.models import BlogPost
from blogApp.documents import BlogPostDocument
from projectsApp.models import Project
from projectsApp.documents import ProjectDocument, PageDocument



class HomeView( TemplateView ):
	'''
	Home view.
	'''
	
	template_name = 'siteApp/home.html'
	
	
	def get_context_data( self, **kwargs ):
		context = super().get_context_data( **kwargs )
		
		context['projects'] = Project.objects.filter( highlight = True )[:5]
		context['posts'] = BlogPost.objects.all()[:5]
		
		return context


class AboutMeView( TemplateView ):
	'''
	About me view.
	'''
	
	template_name = 'siteApp/about_me.html'


class SearchView( ListView ):
	'''
	Site-wide search.
	'''
	
	paginate_by = 10
	template_name = 'siteApp/search.html'
	context_object_name = 'results'
	
	
	def setup( self, request, *args, **kwargs ):
		self.searchQuery = request.GET.get( 'query', '' )
		
		return super().setup( request, *args, **kwargs )
	
	def get_queryset( self ):
		docTypes = [
			ProjectDocument,
			PageDocument,
			BlogPostDocument,
		]
		
		return DslSearch( doc_type = docTypes ).query(
			'multi_match',
			query = self.searchQuery,
			fuzziness = 2
		).execute()
	
	def get_context_data( self, **kwargs ):
		context = super().get_context_data( **kwargs )
		
		context['searchQuery'] = self.searchQuery
		
		# Pagination.
		if context['page_obj'].has_previous():
			url = reverse( 'siteApp:search', kwargs = { 'page': context['page_obj'].previous_page_number() } )
			queryString = urlencode( { 'query': self.searchQuery } )
			
			context['previousPageUrl'] = f'{url}?{queryString}'
		
		if context['page_obj'].has_next():
			url = reverse( 'siteApp:search', kwargs = { 'page': context['page_obj'].next_page_number() } )
			queryString = urlencode( { 'query': self.searchQuery } )
			
			context['nextPageUrl'] = f'{url}?{queryString}'
		
		return context


class SitemapView( TemplateView ):
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