#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.test import TestCase

from .models import Category, Project, Page



def createProject():
	category = Category.objects.create()
	
	return Project.objects.create( category = category )


def createPages( project, number ):
	for index in range( 1, number + 1 ):
		Page.objects.create( project = project, number = index )



class ProjectModelTests( TestCase ):
	
	def testSinglePageWithZeroPages( self ):
		'''
		single_page should return True if the project has no pages.
		'''
		
		project = createProject()
		
		self.assertIs( project.single_page, True )
	
	
	def testSinglePageWithOnePage( self ):
		'''
		single_page should return False if the project has one or more pages.
		'''
		
		project = createProject()
		createPages( project, 1 )
		
		self.assertIs( project.single_page, False )
	
	
	def testLastEditedWithZeroPages( self ):
		'''
		last_edited should return base_last_edited if the project has zero pages.
		'''
		
		project = createProject()
		
		self.assertEqual( project.last_edited, project.base_last_edited )
	
	
	def testLastEditedWithEditedPage( self ):
		'''
		last_edited should return page.last_edited of the last edited page if the project has one or more pages.
		'''
		
		project = createProject()
		createPages( project, 10 )
		
		# Not last edited yet.
		lastEditPage = Page.objects.all()[4]
		self.assertNotEqual( project.last_edited, lastEditPage.last_edited )
		
		# Now last edited.
		lastEditPage.save()
		self.assertEqual( project.last_edited, lastEditPage.last_edited )
	
	
	def testLastEditedWithEditedProject( self ):
		'''
		last_edited should return base_last_edited if the project was edited after the pages.
		'''
		
		project = createProject()
		createPages( project, 10 )
		
		# Not last edited yet.
		self.assertNotEqual( project.last_edited, project.base_last_edited )
		
		# Now last edited.
		project.save()
		self.assertEqual( project.last_edited, project.base_last_edited )