#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.shortcuts import render
from django.urls import reverse



def home( httpRequest ):
	'''
	Home view.
	'''
	
	return render( httpRequest, 'siteApp/home.html' )


def professional( httpRequest ):
	'''
	Professional view.
	'''
	
	return render( httpRequest, 'siteApp/professional.html' )


def about_me( httpRequest ):
	'''
	About me view.
	'''
	
	return render( httpRequest, 'siteApp/about_me.html' )


def sitemap( httpRequest ):
	'''
	sitemap.xml.
	'''
	
	urls = []
	
	views = [
		'siteApp:home',
	]
	
	for view in views:
		urls.append( httpRequest.build_absolute_uri( reverse( view ) ) )
	
	return render( httpRequest, 'siteApp/sitemap.xml', { 'urls': urls }, content_type = 'text/xml' )