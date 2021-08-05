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


def imageGalleryPlugin( md, instance ):
	'''
	Plugin for rendering image galleries using Django UserImage.
	
	Syntax: #[type](identifier1, identifier2, identifier3)
	'''
	
	md.inline.ruler.before( 'image', 'imageGallery', partial( imageGallery, instance = instance ) )
	# TODO
	# md.block.ruler.before( 'paragraph', 'imageGallery', partial( imageGallery, instance = instance ) )


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
def imageGallery( state, silent, instance ):
	'''
	Rule
	'''
	
	oldPos = state.pos
	
	try:
		parseStream( state, '#' )
		cssClassStart		= parseStream( state, '[' )
		cssClassEnd			= parseStream( state, ']' )
		identifiersStart	= parseStream( state, '(' )
		identifiersEnd		= parseStream( state, ')' )
	except CharacterNotFound:
		state.pos = oldPos
		return False
	
	if not silent:
		cssClass = state.src[cssClassStart:cssClassEnd - 1]
		identifiers = state.src[identifiersStart:identifiersEnd - 1]
		identifiers = [ identifier.strip() for identifier in identifiers.split( ',' ) ]
		
		userImages = [ userImage for userImage in instance.user_images.all() if userImage.identifier in identifiers ]
		
		renderedTemplate = loader.render_to_string(
			'commonApp/image_gallery.html',
			{ 'userImages': userImages, 'cssClass': cssClass },
		)
		
		state.push( 'html_block', '', 0 ).content = renderedTemplate
	
	return True