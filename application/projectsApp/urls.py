# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views



app_name = 'projectsApp'

urlpatterns = [
	path( 'projects',										views.Projects.as_view(),		name = 'projects' ),
	path( 'projects/<slug:slug>',							views.ProjectView.as_view(),	name = 'project' ),
	path( 'projects/<slug:slug>/page/<int:page_number>',	views.PageView.as_view(),		name = 'page' ),
]