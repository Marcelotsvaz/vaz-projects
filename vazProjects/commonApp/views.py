#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.http import HttpResponsePermanentRedirect
from django.shortcuts import render
from django.conf import settings



def robots( httpRequest ):
	'''
	robots.txt
	'''
	
	return render( httpRequest, 'commonApp/robots.txt', content_type = 'text/plain' )


def favicon( httpRequest ):
	'''
	favicon.ico
	'''
	
	return HttpResponsePermanentRedirect( settings.STATIC_URL + 'siteApp/images/favicon.png', status = 308 )