# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views



app_name = 'projectsApp'

urlpatterns = [
	path( 'projects',												views.Projects.as_view(),	name = 'projects' ),
	path( 'projects/<slug:project_slug>',							views.project,				name = 'project' ),
	path( 'projects/<slug:project_slug>/page/<int:page_number>',	views.page,					name = 'page' ),
]