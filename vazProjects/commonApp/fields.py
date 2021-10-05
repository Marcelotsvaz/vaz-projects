#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from datetime import date
from functools import partialmethod

from markdown_it import MarkdownIt

from django.db import models
from django.forms import Textarea, ValidationError
from django.utils.translation import gettext_lazy as _
from django.utils.text import normalize_newlines

from . import settings
from .markdown_it_extensions import linkAttributes, imageGalleryPlugin



class TextField( models.TextField ):
	'''
	TextField with normalized line endings.
	'''
	
	
	def get_prep_value( self, value ):
		'''
		Convert the field object to a database-agnostic string.
		'''
		
		return normalize_newlines( super().get_prep_value( value ) )



class MarkdownField( TextField ):
	'''
	TextField rendered with Markdown.
	'''
	
	def _render_FIELD( self, field ):
		'''
		Return a rendered version of the MarkdownField.
		'''
		
		renderer = MarkdownIt( 'zero' )
		
		renderer.enable( settings.MARKDOWN_FEATURES )
		renderer.options['breaks'] = True
		
		renderer.use( imageGalleryPlugin, markdownImages = self.getMarkdownImages() )
		renderer.add_render_rule( "link_open", linkAttributes )
		
		return renderer.render( getattr( self, field.attname ) )
	
	
	def contribute_to_class( self, cls, name, private_only = False ):
		'''
		Register the field with the model class it belongs to.
		'''
		
		super().contribute_to_class( cls, name, private_only )
		
		setattr( cls, f'render_{name}', partialmethod( MarkdownField._render_FIELD, field = self ) )