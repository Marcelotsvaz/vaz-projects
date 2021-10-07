#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from unittest.mock import Mock

from django.test import TestCase

from markdown_it import MarkdownIt

from .markdown_it_extensions import linkAttributes, imageGalleryPlugin
from . import settings



class MarkdownExtensionsTests( TestCase ):
	
	def testMarkdownLinkNoopener( self ):
		'''
		Test if rel="noopener" is added to Markdown links.
		'''
		
		inputText = '[LinkTitle](LinkAddress)'
		
		renderer = MarkdownIt( 'zero' )
		renderer.enable( [ 'link' ] )
		renderer.add_render_rule( "link_open", linkAttributes )
		
		self.assertInHTML( '<a href="LinkAddress" rel="noopener">LinkTitle</a>', renderer.render( inputText ) )


class MarkdownImageGalleryTests( TestCase ):
	
	def getRenderer( self, markdownImages = [] ):
		renderer = MarkdownIt( 'zero', options_update = settings.MARKDOWN_OPTIONS )
		renderer.enable( settings.MARKDOWN_FEATURES )
		renderer.use( imageGalleryPlugin, markdownImages = markdownImages )
		
		return renderer
	
	def getMockUserImage( self, name = 'image' ):
		mock = Mock()
		mock.identifier = f'{name}-identifier'
		mock.image_small.url = f'{name}-image_small-url'
		mock.image_large.url = f'{name}-image_large-url'
		mock.attribution = f'{name}-attribution'
		mock.alt = f'{name}-alt'
		
		return mock
	
	
	# Test interactions with other Markdown features.
	#---------------------------------------------------------------------------
	def testEmptyMarkdownImageGallery( self ):
		'''
		A gallery with no identifiers should render a empty `div`.
		'''
		
		inputText = '#[]()'
		
		renderer = self.getRenderer()
				
		self.assertHTMLEqual( '<div class="imageGallery"></div>', renderer.render( inputText ) )
	
	
	def testMarkdownImageGalleryBetweenParagraphs( self ):
		'''
		Test gallery interaction with paragraphs.
		'''
		
		inputText = 'Some text!\n#[]()\nSome more text!'
		
		renderer = self.getRenderer()
		
		self.assertHTMLEqual( '<p>Some text!</p><div class="imageGallery"></div><p>Some more text!</p>', renderer.render( inputText ) )
	
	
	def testMarkdownImageGalleryBetweenHeaders( self ):
		'''
		Test gallery interaction with headers.
		'''
		
		inputText = '# Header Text!\n#[]()\n# Another Header Text!'
		
		renderer = self.getRenderer()
		
		self.assertHTMLEqual( '<h1>Header Text!</h1><div class="imageGallery"></div><h1>Another Header Text!</h1>', renderer.render( inputText ) )
	
	
	def testMarkdownImageGalleryWithExtraText( self ):
		'''
		No extra characters are allowed on the same line.
		'''
		
		inputText = '#[]() extra'
		
		renderer = self.getRenderer()
		
		self.assertHTMLEqual( '<p>#<a href=""></a> extra</p>', renderer.render( inputText ) )
	
	
	# Test classes.
	#---------------------------------------------------------------------------
	def testMarkdownImageGalleryWithOneClass( self ):
		'''
		Test if a custom css class is applied.
		'''
		
		inputText = '#[testClass]()'
		
		renderer = self.getRenderer()
		
		self.assertHTMLEqual( '<div class="imageGallery testClass"></div>', renderer.render( inputText ) )
	
	
	def testMarkdownImageGalleryWithMultipleClasses( self ):
		'''
		Test if multiple css classes are applied.
		'''
		
		inputText = '#[testClass1 testClass2]()'
		
		renderer = self.getRenderer()
		
		self.assertHTMLEqual( '<div class="imageGallery testClass1 testClass2"></div>', renderer.render( inputText ) )
	
	
	# Test image output.
	#---------------------------------------------------------------------------
	def testMarkdownImageGalleryWithWildcard( self ):
		'''
		Test if all images are rendered when a wildcard is used as a identifier.
		'''
		
		image1 = self.getMockUserImage( name = 'image1' )
		image2 = self.getMockUserImage( name = 'image2' )
		inputText = '#[](*)'
		
		renderer = self.getRenderer( markdownImages = [ image1, image2 ] )
		renderedOutput = renderer.render( inputText )
		
		self.assertInHTML( f'<img src="{image1.image_small.url}" alt="{image1.alt}">', renderedOutput )
		self.assertInHTML( f'<img src="{image2.image_small.url}" alt="{image2.alt}">', renderedOutput )
	
	
	def testMarkdownImageGalleryWithAllIdentifiers( self ):
		'''
		Test if all images are rendered when they are manually specified.
		'''
		
		image1 = self.getMockUserImage( name = 'image1' )
		image2 = self.getMockUserImage( name = 'image2' )
		inputText = f'#[]({image1.identifier}, {image2.identifier})'
		
		renderer = self.getRenderer( markdownImages = [ image1, image2 ] )
		renderedOutput = renderer.render( inputText )
		
		self.assertInHTML( f'<img src="{image1.image_small.url}" alt="{image1.alt}">', renderedOutput )
		self.assertInHTML( f'<img src="{image2.image_small.url}" alt="{image2.alt}">', renderedOutput )
	
	
	def testMarkdownImageGalleryWithSomeIdentifiers( self ):
		'''
		Test if only the specified images are rendered when they are manually specified.
		'''
		
		image1 = self.getMockUserImage( name = 'image1' )
		image2 = self.getMockUserImage( name = 'image2' )
		image3 = self.getMockUserImage( name = 'image3' )
		inputText = f'#[]({image2.identifier})'
		
		renderer = self.getRenderer( markdownImages = [ image1, image2, image3 ] )
		renderedOutput = renderer.render( inputText )
		
		self.assertNotIn( image1.image_small.url, renderedOutput )
		self.assertInHTML( f'<img src="{image2.image_small.url}" alt="{image2.alt}">', renderedOutput )
		self.assertNotIn( image3.image_small.url, renderedOutput )
	
	
	def testMarkdownImageGalleryWithUndefinedIdentifiers( self ):
		'''
		Test if undefined identifiers are ignored.
		'''
		
		image1 = self.getMockUserImage( name = 'image1' )
		image2 = self.getMockUserImage( name = 'image2' )
		inputText = f'#[]({image1.identifier}, {image2.identifier})'
		
		renderer = self.getRenderer( markdownImages = [ image2 ] )
		renderedOutput = renderer.render( inputText )
		
		self.assertInHTML( f'<img src="{image2.image_small.url}" alt="{image2.alt}">', renderedOutput )