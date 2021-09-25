#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.test import TestCase, Client
from django.db.models import Max
from django.urls import reverse

from .models import Category, Project, Page



def createProject( **kwargs ):
	category = Category.objects.get_or_create()[0]
	
	return Project.objects.create( category = category, **kwargs )


def createPages( project, quantity, **kwargs ):
	lastPageNumber = project.pages.aggregate( last_page = Max( 'number' ) )['last_page'] or 0
	lastPage = None
	
	for index in range( lastPageNumber + 1, lastPageNumber + quantity + 1 ):
		lastPage = Page.objects.create( project = project, number = index, **kwargs )
	
	return lastPage



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
		lastEditedPage = createPages( project, 5 )
		createPages( project, 5 )
		project.publish()
		
		# Not last edited yet.
		self.assertNotEqual( project.last_edited, lastEditedPage.last_edited )
		
		# Now last edited.
		lastEditedPage.refresh_from_db()
		lastEditedPage.save()
		self.assertEqual( project.last_edited, lastEditedPage.last_edited )
	
	
	def testLastEditedWithEditedProject( self ):
		'''
		last_edited should return base_last_edited if the project was edited after the pages.
		'''
		
		project = createProject()
		lastPage = createPages( project, 10 )
		project.publish()
		
		# Not last edited yet.
		lastPage.refresh_from_db()
		lastPage.save()
		self.assertNotEqual( project.last_edited, project.base_last_edited )
		
		# Now last edited.
		project.save()
		self.assertEqual( project.last_edited, project.base_last_edited )
	
	
	def testLastEditedWithUnpublishedPages( self ):
		'''
		last_edited should return base_last_edited even after new pages are created but not published.
		'''
		
		project = createProject()
		createPages( project, 5 )	# Will be published.
		project.publish()			# Will update the project after all pages.
		createPages( project, 5 )	# Won't be published.
		
		# New pages not published.
		self.assertEqual( project.last_edited, project.base_last_edited )


class ProjectsViewTests( TestCase ):
	
	def testPublishedProject( self ):
		'''
		Published projects should appear in the projects page.
		'''
		
		name = 'Test-Project'
		slug = name.lower()
		
		createProject( slug = slug, name = name ).publish()
		
		response = Client().get( reverse( 'projectsApp:projects' ) )
		
		self.assertContains( response, slug )
		self.assertContains( response, name )
	
	
	def testUnpublishedProject( self ):
		'''
		Unpublished projects shouldn't appear in the projects page.
		'''
		
		name = 'Test-Project'
		slug = name.lower()
		
		createProject( slug = slug, name = name )
		
		response = Client().get( reverse( 'projectsApp:projects' ) )
		
		self.assertNotContains( response, slug )
		self.assertNotContains( response, name )


class ProjectViewTests( TestCase ):
	
	def testPublishedProject( self ):
		'''
		Published project should be accessible.
		'''
		
		name = 'Test-Project'
		slug = name.lower()
		
		createProject( slug = slug, name = name ).publish()
		
		response = Client().get( reverse( 'projectsApp:project', args = [ slug ] ) )
		
		self.assertContains( response, name )
	
	
	def testUnpublishedProject( self ):
		'''
		Unpublished project should return 404, not found.
		'''
		
		name = 'Test-Project'
		slug = name.lower()
		
		createProject( slug = slug, name = name )
		
		response = Client().get( reverse( 'projectsApp:project', args = [ slug ] ) )
		
		self.assertNotContains( response, name, status_code = 404 )
	
	
	def testPublishedPage( self ):
		'''
		Published project page should be accessible.
		'''
		
		projectName = 'Test-Project'
		projectSlug = projectName.lower()
		pageName = 'Test-Page'
		
		project = createProject( slug = projectSlug, name = projectName )
		lastPage = createPages( project, 5, name = pageName )
		project.publish()
		
		response = Client().get( reverse( 'projectsApp:project', args = [ projectSlug, lastPage.number ] ) )
		
		self.assertContains( response, pageName )
	
	
	def testUnpublishedPage( self ):
		'''
		Unpublished project page should return 404, not found.
		'''
		
		projectName = 'Test-Project'
		projectSlug = projectName.lower()
		pageName = 'Test-Page'
		
		project = createProject( slug = projectSlug, name = projectName )
		project.publish()
		lastPage = createPages( project, 5, name = pageName )
		
		response = Client().get( reverse( 'projectsApp:project', args = [ projectSlug, lastPage.number ] ) )
		
		self.assertNotContains( response, pageName, status_code = 404 )