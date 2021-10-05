#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.test import TestCase

from markdown_it import MarkdownIt

from .markdown_it_extensions import linkAttributes, imageGalleryPlugin



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
	
	def testEmptyMarkdownImageGallery( self ):
		'''
		A Markdown gallery with no identifiers should render a empty `div`.
		'''
		
		inputText = '#[]()'
		
		renderer = MarkdownIt( 'zero' )
		renderer.use( imageGalleryPlugin, markdownImages = [] )
		
		self.assertInHTML( '<div class="imageGallery"></div>', renderer.render( inputText ) )
	
	
	def testMarkdownImageGalleryWithOneClass( self ):
		'''
		Test if a custom css class is applied.
		'''
		
		inputText = '#[testClass]()'
		
		renderer = MarkdownIt( 'zero' )
		renderer.use( imageGalleryPlugin, markdownImages = [] )
		
		self.assertInHTML( '<div class="imageGallery testClass"></div>', renderer.render( inputText ) )
	
	
	def testMarkdownImageGalleryWithMultipleClasses( self ):
		'''
		Test if multiple css classes are applied.
		'''
		
		inputText = '#[testClass1 testClass2]()'
		
		renderer = MarkdownIt( 'zero' )
		renderer.use( imageGalleryPlugin, markdownImages = [] )
		
		self.assertInHTML( '<div class="imageGallery testClass1 testClass2"></div>', renderer.render( inputText ) )