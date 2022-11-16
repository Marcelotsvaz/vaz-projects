# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from xml.etree import ElementTree

from django.test import TestCase, Client
from django.urls import reverse

from projectsApp.tests import TestUtils as ProjectTestUtils
from blogApp.tests import TestUtils as BlogPostTestUtils



class HomeViewTests( TestCase ):
	
	def testPublishedAndHighlightedProject( self ):
		'''
		Published and highlighted projects should appear in the home page.
		'''
		
		ProjectTestUtils.createProject( highlight = True ).publish()
		
		response = Client().get( reverse( 'siteApp:home' ) )
		
		self.assertContains( response, ProjectTestUtils.projectSlug )
		self.assertContains( response, ProjectTestUtils.projectName )
	
	
	def testUnhighlightedProject( self ):
		'''
		Unhighlighted projects shouldn't appear in the home page.
		'''
		
		ProjectTestUtils.createProject().publish()
		
		response = Client().get( reverse( 'siteApp:home' ) )
		
		self.assertNotContains( response, ProjectTestUtils.projectSlug )
		self.assertNotContains( response, ProjectTestUtils.projectName )
	
	
	def testUnpublishedProject( self ):
		'''
		Unpublished projects shouldn't appear in the home page.
		'''
		
		ProjectTestUtils.createProject( highlight = True )
		
		response = Client().get( reverse( 'siteApp:home' ) )
		
		self.assertNotContains( response, ProjectTestUtils.projectSlug )
		self.assertNotContains( response, ProjectTestUtils.projectName )
	
	
	def testPublishedBlogPost( self ):
		'''
		Published posts should appear in the home page.
		'''
		
		BlogPostTestUtils.createPost().publish()
		
		response = Client().get( reverse( 'siteApp:home' ) )
		
		self.assertContains( response, BlogPostTestUtils.postSlug )
		self.assertContains( response, BlogPostTestUtils.postTitle )
	
	
	def testUnpublishedBlogPost( self ):
		'''
		Unpublished posts shouldn't appear in the home page.
		'''
		
		BlogPostTestUtils.createPost()
		
		response = Client().get( reverse( 'siteApp:home' ) )
		
		self.assertNotContains( response, BlogPostTestUtils.postSlug )
		self.assertNotContains( response, BlogPostTestUtils.postTitle )



class SitemapViewTests( TestCase ):
	
	def testSitemapValidXml( self ):
		'''
		Test if the sitemap.xml is valid XML by running it through a parser.
		'''
		
		project = ProjectTestUtils.createProject()
		page = ProjectTestUtils.createPages( project, 5 )
		project.publish( publishPages = True )
		
		post = BlogPostTestUtils.createPost()
		post.publish()
		
		response = Client().get( reverse( 'siteApp:sitemap' ) )
		
		ElementTree.fromstring( response.content )
		self.assertContains( response, project.get_absolute_url() )
		self.assertContains( response, page.get_absolute_url() )
		self.assertContains( response, post.get_absolute_url() )