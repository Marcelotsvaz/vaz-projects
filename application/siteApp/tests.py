# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.test import TestCase, Client
from django.urls import reverse

from xml.etree import ElementTree



class SitemapViewTests( TestCase ):
	
	def testSitemapValidXml( self ):
		'''
		Test if the sitemap.xml is valid XML by running it through a parser.
		'''
		
		response = Client().get( reverse( 'siteApp:sitemap' ) )
		ElementTree.fromstring( response.content )