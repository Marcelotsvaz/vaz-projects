# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from pathlib import PurePath

from django.core.management.base import BaseCommand
from django.db.models import FileField
from django.core.files.storage import default_storage

from ._util import getAllModels, getFields



class Command( BaseCommand ):
	'''
	Delete all files in the media folder that are not referenced by any model.
	'''
	
	help = 'Delete all files in the media folder that are not referenced by any model.'
	
	
	def handle( self, *args, **options ):
		# TODO: Add proper regex ignore from parameters.
		ignore = [
			PurePath( 'cache' ),
		]
		
		allFiles = self.getAllFiles( ignore = ignore )
		self.stdout.write( self.style.WARNING( f'{len( allFiles )} files on storage.' ) )
		
		referencedFiles = self.getReferencedFiles()
		self.stdout.write( self.style.WARNING( f'{len( referencedFiles )} files referenced in models.' ) )
		
		orphanatedFiles = allFiles.difference( referencedFiles )
		self.stdout.write( self.style.NOTICE( f'{len( orphanatedFiles )} orphanated files.' ) )
		
		self.deleteFiles( orphanatedFiles )
		
		self.stdout.write( self.style.SUCCESS( 'Done.' ) )
	
	
	def getAllFiles( self, basePath = PurePath(), ignore = [] ):
		'''
		Recursively return a set of all files in basePath.
		'''
		
		if basePath in ignore:
			return set()
		
		directories, fileNames = default_storage.listdir( str( basePath ) )
		
		appendPath = lambda fileName: basePath / fileName
		directories = set( map( appendPath, directories ) )
		fileNames = set( map( appendPath, fileNames ) )
		
		for directory in directories:
			fileNames.update( self.getAllFiles( directory, ignore ) )
		
		return fileNames
	
	
	def getReferencedFiles( self ):
		'''
		Return a set of all files referenced in models.
		'''
		
		referencedFiles = set()
		for Model in getAllModels():
			referencedFiles.update( self.getModelFiles( Model ) )
		
		return referencedFiles
	
	
	def getModelFiles( self, Model ):
		'''
		Return a set of all files referenced in a specific model.
		'''
		
		# Get the name of all FileFields in the model.
		fileFields = getFields( Model, FileField )
		
		if len( fileFields ) == 0:
			return set()
		
		# For all instances of the model, get the path of all the FileFields.
		files = set()
		for instance in Model.objects.all():
			for fieldName in fileFields:
				file = getattr( instance, fieldName )
				
				if file:
					files.add( PurePath( file.name ) )
		
		return files
	
	
	def deleteFiles( self, files ):
		'''
		Delete all files using the default storage.
		'''
		
		for fileName in files:
			default_storage.delete( fileName )
			self.stdout.write( self.style.WARNING( f'Deleted {fileName}.' ) )