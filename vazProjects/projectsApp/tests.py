#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.test import TestCase

from .models import Category, Project, Page



class ProjectModelTests( TestCase ):
	
	def testSinglePageWithZeroPages( self ):
		'''
		single_page should return True if the project has no pages.
		'''
		
		category = Category()
		category.save()
		
		project = Project(
			category = category,
		)
		project.save()
		
		self.assertIs( project.single_page, True )
	
	
	def testSinglePageWithOnePage( self ):
		'''
		single_page should return False if the project has one or more pages.
		'''
		
		category = Category()
		category.save()
		
		project = Project(
			category = category,
		)
		project.save()
		
		page = Page(
			project = project,
			number = 1,
		)
		page.save()
		
		self.assertIs( project.single_page, False )
	
	
	def testLastEditedWithZeroPages( self ):
		'''
		last_edited should return base_last_edited if the project has zero pages.
		'''
		
		category = Category()
		category.save()
		
		project = Project(
			category = category,
		)
		project.save()
		
		self.assertEqual( project.last_edited, project.base_last_edited )
	
	
	def testLastEditedWithEditedPage( self ):
		'''
		last_edited should return page.last_edited of the last edited page if the project has one or more pages.
		'''
		
		category = Category()
		category.save()
		
		project = Project(
			category = category,
		)
		project.save()
		
		for index in range( 1, 11 ):
			page = Page(
				project = project,
				number = index,
			)
			page.save()
		
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
		
		category = Category()
		category.save()
		
		project = Project(
			category = category,
		)
		project.save()
		
		for index in range( 1, 11 ):
			page = Page(
				project = project,
				number = index,
			)
			page.save()
		
		# Not last edited yet.
		self.assertNotEqual( project.last_edited, project.base_last_edited )
		
		# Now last edited.
		project.save()
		self.assertEqual( project.last_edited, project.base_last_edited )