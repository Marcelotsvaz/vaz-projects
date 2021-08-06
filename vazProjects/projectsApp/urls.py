#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views



app_name = 'projectsApp'

urlpatterns = [
	path( 'projects',						views.projects,	name = 'projects' ),
	path( 'projects/<slug:project_slug>',	views.project,	name = 'project' ),
]