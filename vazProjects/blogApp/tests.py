#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from base64 import b64decode
from unittest.mock import patch

from django.test import TestCase, Client, override_settings
from django.urls import reverse
from django.conf import settings
from django.core.files.uploadedfile import SimpleUploadedFile
from django.contrib.auth import get_user_model

from .models import BlogPost



class TestUtils():
	
	# Defaults.
	postSlug = 'test-post'
	postTitle = 'Test-Post'
	
	
	@classmethod
	def testImage( cls ):
		'''
		Return a instance of SimpleUploadedFile containing a 2px x 2px JPG image.
		'''
		
		return SimpleUploadedFile(
			'test-image.png',
			b64decode( 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=' ),
		)
	
	
	@classmethod
	@override_settings( MEDIA_ROOT = settings.TESTS_MEDIA_ROOT )
	def createPost( cls, **kwargs ):
		'''
		Create a test post and return it. Images and a slug are supplied to properly render templates.
		'''
		
		defaults = {
			'slug': cls.postSlug,
			'title': cls.postTitle,
			'author': get_user_model().objects.get_or_create()[0],
			'banner_original': cls.testImage(),
		}
		defaults.update( kwargs )
		
		return BlogPost.objects.create( **defaults )



@override_settings( MEDIA_ROOT = settings.TESTS_MEDIA_ROOT )
class BlogViewTests( TestCase ):
	
	@patch( 'blogApp.models.getDisqusCommentCount', autospec = True, return_value = 0 )
	def testPublishedBlogPost( self, mock ):
		'''
		Published posts should appear in the blog page.
		'''
		
		TestUtils.createPost().publish()
		
		response = Client().get( reverse( 'blogApp:blog' ) )
		
		self.assertContains( response, TestUtils.postSlug )
		self.assertContains( response, TestUtils.postTitle )
	
	
	def testUnpublishedBlogPost( self ):
		'''
		Unpublished posts shouldn't appear in the blog page.
		'''
		
		TestUtils.createPost()
		
		response = Client().get( reverse( 'blogApp:blog' ) )
		
		self.assertNotContains( response, TestUtils.postSlug )
		self.assertNotContains( response, TestUtils.postTitle )



@override_settings( MEDIA_ROOT = settings.TESTS_MEDIA_ROOT )
class BlogPostViewTests( TestCase ):
	
	def testPublishedBlogPost( self ):
		'''
		Published posts should be accessible.
		'''
		
		TestUtils.createPost().publish()
		
		response = Client().get( reverse( 'blogApp:post', args = [ TestUtils.postSlug ] ) )
		
		self.assertContains( response, TestUtils.postTitle )
	
	
	def testUnpublishedBlogPost( self ):
		'''
		Unpublished posts should return 404, not found.
		'''
		
		TestUtils.createPost()
		
		response = Client().get( reverse( 'blogApp:post', args = [ TestUtils.postSlug ] ) )
		
		self.assertNotContains( response, TestUtils.postTitle, status_code = 404 )