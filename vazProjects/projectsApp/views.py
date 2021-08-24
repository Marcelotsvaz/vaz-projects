#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import ListView
from django.shortcuts import render, get_object_or_404

from .models import Project, Page



class Projects( ListView ):
	'''
	Projects view.
	'''
	
	template_name = 'projectsApp/projects.html'
	context_object_name = 'projects'
	
	def get_queryset(self):
		return Project.objects.filter( draft = False )


def project( httpRequest, project_slug, page_number = None ):
	'''
	Project view.
	'''
	
	project = get_object_or_404( Project, slug = project_slug, draft = False )
	
	if page_number:
		page = get_object_or_404( Page, project = project, number = page_number )
	else:
		page = None
	
	return render( httpRequest, 'projectsApp/project.html', { 'project': project, 'currentPage': page } )