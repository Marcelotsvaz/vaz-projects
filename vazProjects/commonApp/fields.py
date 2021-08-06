#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from datetime import date
from functools import partialmethod

from django.db import models
from django.forms import Textarea, ValidationError
from django.utils.translation import gettext_lazy as _
from django.utils.text import normalize_newlines

from markdown_it import MarkdownIt

from .markdown_it_extensions import linkAttributes, imageGalleryPlugin



class DateListField( models.Field ):
	'''
	Store a list of datetime.date objects.
	'''
	
	description = _('List of dates')
	
	
	def __init__(
		self,
		*args,
		separator = ' ',
		help_text = _('ISO formatted dates separated by space. Ex.: "2020-12-20 2020-12-21"'),
		**kargs ):
		
		self.separator = separator
		super().__init__( *args, help_text = help_text, **kargs )
	
	
	def deconstruct( self ):
		name, path, args, kwargs = super().deconstruct()
		
		if self.separator != ' ':
			kwargs['separator'] = self.separator
		
		return name, path, args, kwargs
	
	
	def get_internal_type( self ):
		return 'TextField'
	
	
	def to_python( self, value ):
		'''
		Convert a string, a field object or None to a field object.
		'''
		if value == '' or value is None:
			return []
		elif isinstance( value, list ) and all( isinstance( item, date ) for item in value ):
			return value
		else:
			try:
				return [ date.fromisoformat( isoDate ) for isoDate in value.split( self.separator ) ]
			except ValueError as error:
				raise ValidationError( error )
	
	
	def from_db_value( self, value, expression, connection ):
		'''
		Convert a string from the database to a field object.
		'''
		return self.to_python( value )
	
	
	def get_prep_value( self, value ):
		'''
		Convert the field object to a database-agnostic string.
		'''
		value = super().get_prep_value( value )
		return self.separator.join( str( exit ) for exit in value )
	
	
	def value_from_object( self, obj ):
		'''
		Convert the field object to a string suitable for forms.
		'''
		return self.get_prep_value( super().value_from_object( obj ) )
	
	
	def formfield( self, **kwargs ):
		return super().formfield( widget = Textarea, **kwargs )



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
	
	def _FIELD_rendered( self, field ):
		'''
		Return a rendered version of the MarkdownField.
		'''
		
		renderer = MarkdownIt( 'zero' )
		
		renderer.enable( [
			'heading',
			'list',
			'emphasis',
			'newline',
			'link'
		] )
		renderer.options['breaks'] = True
		
		renderer.use( imageGalleryPlugin, instance = self )
		renderer.add_render_rule( "link_open", linkAttributes )
		
		return renderer.render( getattr( self, field.attname ) )
	
	
	def contribute_to_class( self, cls, name, private_only = False ):
		'''
		Register the field with the model class it belongs to.
		'''
		
		super().contribute_to_class( cls, name, private_only )
		
		setattr( cls, f'{name}_rendered', partialmethod( MarkdownField._FIELD_rendered, field = self ) )