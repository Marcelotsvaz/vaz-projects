# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import TemplateView, RedirectView
from django.conf import settings

from rest_framework.views import APIView
from rest_framework.response import Response

from .misc import getDisqusCommentCount



class CommentsCountApi( APIView ):
	'''
	Comments count API.
	'''
	
	def get( self, request ):
		commentsCount = {}
		
		for identifier in request.query_params.getlist( 'identifiers' ):
			commentsCount[identifier] = getDisqusCommentCount( identifier )
		
		return Response( commentsCount )


class RobotsView( TemplateView ):
	'''
	robots.txt
	'''
	
	template_name = 'commonApp/robots.txt'
	content_type = 'text/plain'


class FaviconView( RedirectView ):
	'''
	favicon.ico
	
	Redirect /favicon.ico to our CDN since we don't serve static files from
	our instance and we can't set this URL in the HTML.
	'''
	
	url = settings.STATIC_URL + 'siteApp/images/favicon.svg'
	
	
	def get( self, *args, **kwargs ):
		response = super().get( *args, **kwargs )
		
		response.status_code = 308	# Permanent redirect.
		
		return response