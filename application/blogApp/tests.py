# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model

from .models import BlogPost



class TestUtils():
	
	# Defaults.
	postSlug = 'test-post'
	postTitle = 'Test-Post'
	
	
	@classmethod
	def createPost( cls, **kwargs ):
		'''
		Create a test post and return it. Images and a slug are supplied to properly render templates.
		'''
		
		defaults = {
			'slug': cls.postSlug,
			'title': cls.postTitle,
			'author': get_user_model().objects.get_or_create()[0],
		}
		defaults.update( kwargs )
		
		return BlogPost.objects.create( **defaults )



class BlogViewTests( TestCase ):
	
	def testPublishedBlogPost( self ):
		'''
		Published posts should appear in the blog page.
		'''
		
		TestUtils.createPost().publish()
		
		response = self.client.get( reverse( 'blogApp:blog' ) )
		
		self.assertContains( response, TestUtils.postSlug )
		self.assertContains( response, TestUtils.postTitle )
	
	
	def testUnpublishedBlogPost( self ):
		'''
		Unpublished posts shouldn't appear in the blog page.
		'''
		
		TestUtils.createPost()
		
		response = self.client.get( reverse( 'blogApp:blog' ) )
		
		self.assertNotContains( response, TestUtils.postSlug )
		self.assertNotContains( response, TestUtils.postTitle )



class BlogPostViewTests( TestCase ):
	
	def testPublishedBlogPost( self ):
		'''
		Published posts should be accessible.
		'''
		
		TestUtils.createPost().publish()
		
		response = self.client.get( reverse( 'blogApp:post', args = [ TestUtils.postSlug ] ) )
		
		self.assertContains( response, TestUtils.postTitle )
	
	
	def testUnpublishedBlogPost( self ):
		'''
		Unpublished posts should return 404, not found.
		'''
		
		TestUtils.createPost()
		
		response = self.client.get( reverse( 'blogApp:post', args = [ TestUtils.postSlug ] ) )
		
		self.assertNotContains( response, TestUtils.postTitle, status_code = 404 )