#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from pathlib import PurePath

from django.core.management.base import BaseCommand
from django.db.models import FileField

from ._util import getAllModels, getFields



class Command( BaseCommand ):
	'''
	Update the name of all FieldFiles using the field's upload_to function.
	'''
	
	help = 'Update the name of all FieldFiles using the field\'s upload_to function.'
	
	
	def handle( self, *args, **options ):
		for Model in getAllModels():
			self.updateModelFilenames( Model )
		
		self.stdout.write( self.style.SUCCESS( 'Done.' ) )
	
	
	def updateModelFilenames( self, Model ):
		'''
		Update the name of all FieldFiles in a model using the field's upload_to function.
		'''
		
		# Get the name of all FileFields in the model.
		fileFields = getFields( Model, FileField )
		
		if len( fileFields ) == 0:
			return
		
		# For all instances of the model, get the path of all the FileFields.
		for instance in Model.objects.all():
			save = False
			
			for fieldName in fileFields:
				fieldFile = getattr( instance, fieldName )
				
				if not fieldFile:
					continue
				
				oldName = PurePath( fieldFile.name )
				newName = fieldFile.field.upload_to( instance, oldName )
				
				if newName == oldName:
					continue
				
				fieldFile.save( newName, fieldFile.file, save = False )
				save = True
				self.stdout.write( self.style.SUCCESS( f'Renamed {oldName} to {newName}.' ) )
			
			if save:
				instance.save()