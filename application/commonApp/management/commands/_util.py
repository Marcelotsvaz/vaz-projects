#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.apps import apps



def getAllModels():
	'''
	Get all models in the project.
	'''
	
	Models = []
	for Model in apps.get_models():
		if Model.__name__ == 'InformationBase':	# TODO: Ignore base of proxy models.
			continue
		
		Models.append( Model )
	
	return Models


def getFields( Model, Field ):
	'''
	Return the name of all fields of type Field in the Model.
	'''
	
	fileFields = []
	for field in Model._meta.fields:
		if isinstance( field, Field ):
			fileFields.append( field.name )
	
	return fileFields