#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from functools import partial

from django.template import loader

from .models import UserImage



def linkAttributes( self, tokens, idx, options, env ):
	'''
	Add target and rel attributes to links.
	'''
	
	tokens[idx].attrSet( 'rel', 'noopener' )
	
	return self.renderToken( tokens, idx, options, env )


def imageGalleryPlugin( md, markdownImages ):
	'''
	Plugin for rendering image galleries using Django UserImage.
	
	Syntax: #[cssClass1 cssClass2](identifier1, identifier2, identifier3)
	'''
	
	md.inline.ruler.before( 'image', 'imageGallery', partial( imageGallery, markdownImages = markdownImages ) )
	# TODO
	# md.block.ruler.before( 'paragraph', 'imageGallery', partial( imageGallery, markdownImages = markdownImages ) )


class CharacterNotFound( Exception ):
	pass


def parseStream( state, char ):
	'''
	Parse the state's stream until char is found or state.posMax is reached.
	'''
	
	while state.pos < state.posMax:
		state.pos = state.pos + 1
		
		if state.src[state.pos - 1] == char:
			return state.pos
	
	raise CharacterNotFound


# Fix empty paragraphs in Markdown content
# def imageGallery( state, startLine, endLine, silent, instance ):
def imageGallery( state, silent, markdownImages ):
	'''
	Rule
	'''
	
	oldPos = state.pos
	
	try:
		parseStream( state, '#' )
		cssClassesStart		= parseStream( state, '[' )
		cssClassesEnd		= parseStream( state, ']' )
		identifiersStart	= parseStream( state, '(' )
		identifiersEnd		= parseStream( state, ')' )
	except CharacterNotFound:
		state.pos = oldPos
		return False
	
	if not silent:
		cssClasses = state.src[cssClassesStart:cssClassesEnd - 1]
		identifiers = state.src[identifiersStart:identifiersEnd - 1]
		
		if identifiers.strip() == '*':
			images = markdownImages
		else:
			identifiers = [ identifier.strip() for identifier in identifiers.split( ',' ) ]
			images = [ image for image in markdownImages if image.identifier in identifiers ]
		
		renderedTemplate = loader.render_to_string(
			'commonApp/image_gallery.html',
			{ 'images': images, 'cssClasses': cssClasses },
		)
		
		state.push( 'html_block', '', 0 ).content = renderedTemplate
	
	return True