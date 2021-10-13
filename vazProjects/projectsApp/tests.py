#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.test import TestCase, Client, override_settings
from django.urls import reverse
from django.db.models import Max
from django.conf import settings
from django.core.files.uploadedfile import SimpleUploadedFile

from base64 import b64decode

from .models import Category, Project, Page



class TestUtils():
	
	# Defaults.
	projectName = 'Test-Project'
	projectSlug = 'test-project'
	
	pageName = 'Test-Page'
	
	
	@classmethod
	def testImage( cls ):
		'''
		Return a instance of SimpleUploadedFile containing a 2px x 2px JPG image.
		'''
		
		return SimpleUploadedFile(
			'test-image.png',
			b64decode( 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=' ),
		)
	
	
	@classmethod
	@override_settings( MEDIA_ROOT = settings.TESTS_MEDIA_ROOT )
	def createProject( cls, **kwargs ):
		'''
		Create a test project and return it. Images and a slug are supplied to properly render templates.
		'''
		
		defaults = {
			'category': Category.objects.get_or_create()[0],
			'name': cls.projectName,
			'slug': cls.projectSlug,
			'banner_original': cls.testImage(),
			'thumbnail_original': cls.testImage(),
		}
		defaults.update( kwargs )
		
		return Project.objects.create( **defaults )
	
	
	@classmethod
	@override_settings( MEDIA_ROOT = settings.TESTS_MEDIA_ROOT )
	def createPages( cls, project, quantity, **kwargs ):
		'''
		Create `quantity` test pages and return the last one. Images are supplied to properly render templates.
		'''
		
		defaults = {
			'project': project,
			'name': cls.pageName,
			'banner_original': cls.testImage(),
			'thumbnail_original': cls.testImage(),
		}
		defaults.update( kwargs )
		
		lastPageNumber = project.pages.aggregate( last_page = Max( 'number' ) )['last_page'] or 0
		lastPage = None
		
		for index in range( lastPageNumber + 1, lastPageNumber + quantity + 1 ):
			lastPage = Page.objects.create( number = index, **defaults )
		
		return lastPage



@override_settings( MEDIA_ROOT = settings.TESTS_MEDIA_ROOT )
class ProjectModelTests( TestCase ):
	
	def testSinglePageWithZeroPages( self ):
		'''
		single_page should return True if the project has no pages.
		'''
		
		project = TestUtils.createProject()
		
		self.assertIs( project.single_page, True )
	
	
	def testSinglePageWithOnePage( self ):
		'''
		single_page should return False if the project has one or more pages.
		'''
		
		project = TestUtils.createProject()
		TestUtils.createPages( project, 1 )
		
		self.assertIs( project.single_page, False )
	
	
	def testLastEditedWithZeroPages( self ):
		'''
		last_edited should return base_last_edited if the project has zero pages.
		'''
		
		project = TestUtils.createProject()
		
		self.assertEqual( project.last_edited, project.base_last_edited )
	
	
	def testLastEditedWithEditedPage( self ):
		'''
		last_edited should return page.last_edited of the last edited page if the project has one or more pages.
		'''
		
		project = TestUtils.createProject()
		lastEditedPage = TestUtils.createPages( project, 5 )
		TestUtils.createPages( project, 5 )
		project.publish( publishPages = True )
		
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
		
		project = TestUtils.createProject()
		lastPage = TestUtils.createPages( project, 10 )
		project.publish( publishPages = True )
		
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
		
		project = TestUtils.createProject()
		project.publish()
		TestUtils.createPages( project, 5 )
		
		# New pages not published.
		self.assertEqual( project.last_edited, project.base_last_edited )



@override_settings( MEDIA_ROOT = settings.TESTS_MEDIA_ROOT )
class ProjectsViewTests( TestCase ):
	
	def testPublishedProject( self ):
		'''
		Published projects should appear in the projects page.
		'''
		
		TestUtils.createProject().publish()
		
		response = Client().get( reverse( 'projectsApp:projects' ) )
		
		self.assertContains( response, TestUtils.projectSlug )
		self.assertContains( response, TestUtils.projectName )
	
	
	def testUnpublishedProject( self ):
		'''
		Unpublished projects shouldn't appear in the projects page.
		'''
		
		TestUtils.createProject()
		
		response = Client().get( reverse( 'projectsApp:projects' ) )
		
		self.assertNotContains( response, TestUtils.projectSlug )
		self.assertNotContains( response, TestUtils.projectName )



@override_settings( MEDIA_ROOT = settings.TESTS_MEDIA_ROOT )
class ProjectViewTests( TestCase ):
	
	def testPublishedProject( self ):
		'''
		Published project should be accessible.
		'''
		
		TestUtils.createProject().publish()
		
		response = Client().get( reverse( 'projectsApp:project', args = [ TestUtils.projectSlug ] ) )
		
		self.assertContains( response, TestUtils.projectName )
	
	
	def testUnpublishedProject( self ):
		'''
		Unpublished project should return 404, not found.
		'''
		
		TestUtils.createProject()
		
		response = Client().get( reverse( 'projectsApp:project', args = [ TestUtils.projectSlug ] ) )
		
		self.assertNotContains( response, TestUtils.projectName, status_code = 404 )
	
	
	def testPublishedPage( self ):
		'''
		Published project page should be accessible.
		'''
		
		project = TestUtils.createProject()
		lastPage = TestUtils.createPages( project, 5 )
		project.publish( publishPages = True )
		
		response = Client().get( reverse( 'projectsApp:project', args = [ TestUtils.projectSlug, lastPage.number ] ) )
		
		self.assertContains( response, TestUtils.pageName )
	
	
	def testUnpublishedPage( self ):
		'''
		Unpublished project page should return 404, not found.
		'''
		
		project = TestUtils.createProject()
		TestUtils.createPages( project, 5 )
		project.publish( publishPages = True )
		lastPage = TestUtils.createPages( project, 5 )
		
		response = Client().get( reverse( 'projectsApp:project', args = [ TestUtils.projectSlug, lastPage.number ] ) )
		
		self.assertNotContains( response, TestUtils.pageName, status_code = 404 )