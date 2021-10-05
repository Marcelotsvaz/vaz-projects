#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from functools import partial
import re

from django.template import loader

from .models import UserImage



def linkAttributes( self, tokens, index, options, env ):
	'''
	Add target and rel attributes to links.
	'''
	
	tokens[index].attrSet( 'rel', 'noopener' )
	
	return self.renderToken( tokens, index, options, env )


def imageGalleryPlugin( md, markdownImages ):
	'''
	Plugin for rendering image galleries using Django UserImage.
	
	Syntax: #[cssClass1 cssClass2](identifier1, identifier2, identifier3)
	'''
	
	md.block.ruler.before(
		'paragraph',
		'imageGallery',
		partial( imageGallery, markdownImages = markdownImages ),
		{ 'alt': [ 'paragraph', 'reference', 'blockquote', 'list' ] }
	)


def imageGallery( state, startLine, endLine, silent, markdownImages ):
	'''
	Rule for image gallery.
	'''
	
	lineContent = state.getLines( startLine, startLine + 1, 0, False ).strip()
	
	# Only run the regex if the first two characters match.
	if not lineContent.startswith( '#[' ):
		return False
	
	match = re.match( r'^#\[(.*)\]\((.*)\)$', lineContent )
	
	if not match:
		return False
	
	cssClasses = match[1]
	identifiers = match[2]
	
	if not silent:
		state.line = startLine + 1
		
		if identifiers.strip() == '*':
			images = markdownImages
		else:
			identifiers = [ identifier.strip() for identifier in identifiers.split( ',' ) ]
			images = [ image for image in markdownImages if image.identifier in identifiers ]
		
		renderedTemplate = loader.render_to_string(
			'commonApp/image_gallery.html',
			{ 'images': images, 'cssClasses': cssClasses },
		)
		
		token = state.push( 'html_block', '', 0 )
		token.content = renderedTemplate
		token.map = [startLine, state.line]
	
	return True