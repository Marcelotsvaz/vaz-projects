#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.forms import BaseGenericInlineFormSet
from django.contrib.contenttypes.admin import GenericTabularInline

from .models import UserImage



class UserImageFormSet( BaseGenericInlineFormSet ):
	'''
	UserImage FormSet.
	'''
	
	def __init__( self, *args, **kargs ):
		self.for_concrete_model = False
		
		super().__init__( *args, **kargs )
	
	
	def save_new( self, form, commit = True ):
		'''
		Workaround for missing for_concrete_model in get_for_model call.
		'''
		
		contentType = ContentType.objects.get_for_model( self.instance, for_concrete_model = self.for_concrete_model )
		
		setattr( form.instance, self.ct_field.get_attname(), contentType.pk )
		setattr( form.instance, self.ct_fk_field.get_attname(), self.instance.pk )
		
		return form.save( commit = commit )
		


class UserImageInLine( GenericTabularInline ):
	'''
	UserImage inline.
	'''
	
	model = UserImage
	formset = UserImageFormSet
	extra = 0
	
	
	# Fieldsets.
	main = {
		'fields': (
			'identifier',
			'alt',
			'attribution',
			'notes',
			'image_original',
		)
	}


	# Edit page options.
	fieldsets = ( ( None, main ), )