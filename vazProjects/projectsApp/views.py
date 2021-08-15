#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.shortcuts import render, get_object_or_404

from .models import Project, Page



def projects( httpRequest ):
	'''
	Projects view.
	'''
	
	projects = Project.objects.filter( draft = False )
	
	return render( httpRequest, 'projectsApp/projects.html', { 'projects': projects } )


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