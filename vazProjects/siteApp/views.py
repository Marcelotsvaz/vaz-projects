#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import TemplateView
from django.urls import reverse



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