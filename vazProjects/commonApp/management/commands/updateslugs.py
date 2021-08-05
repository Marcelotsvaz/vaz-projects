#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.core.management.base import BaseCommand
from django.db.models import SlugField
from django.utils.text import slugify

from ._util import getAllModels



class Command( BaseCommand ):
	'''
	
	'''
	
	help = 'Update the name of all FieldFiles using the field\'s upload_to function.'
	
	
	def handle( self, *args, **options ):
		models = self.getModelsWithSlug()
		self.stdout.write( self.style.SUCCESS( f'{len( models )} models with a SlugField and suitable source field.' ) )
		
		self.update( models )
		
		self.stdout.write( self.style.SUCCESS( 'Done.' ) )
	
	
	def getModelsWithSlug( self ):
		'''
		Return a list of tuples with all models with a suitable SlugField.
		'''
		
		updateTuples = []
		
		for Model in getAllModels():
			slug = None
			source = None
			
			for field in Model._meta.fields:
				if isinstance( field, SlugField ):
					slug = field.name
				elif field.name in [ 'name', 'title' ]:	# TODO: Pass this as a parameter.
					source = field.name
			
			if slug and source:
				updateTuples.append( ( slug, source, Model ) )
		
		return updateTuples
	
	
	def update( self, updateTuples ):
		'''
		Update the SlugField of all models in the list.
		'''
		
		instances = 0
		
		for slug, source, Model in updateTuples:
			for instance in Model.objects.all():
				oldSlug = getattr( instance, slug )
				newSlug = slugify( getattr( instance, source ) )
				
				if newSlug != oldSlug:
					setattr( instance, slug, newSlug )
					instance.save()
					self.stdout.write( self.style.WARNING( f'Old slug: {oldSlug} / New slug: {newSlug}' ) )
					instances = instances + 1
		
		self.stdout.write( self.style.SUCCESS( f'Updated {instances} instances.' ) )