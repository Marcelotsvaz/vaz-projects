#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.shortcuts import render, get_object_or_404

from .models import Project



def projects( httpRequest ):
	'''
	Projects view.
	'''
	
	projects = Project.objects.filter( published = True )
	
	return render( httpRequest, 'projectsApp/projects.html', { 'projects': projects} )


def project( httpRequest, project_slug ):
	'''
	Project view.
	'''
	
	project = get_object_or_404( Project, slug = project_slug, published = True )
	
	return render( httpRequest, 'projectsApp/project.html', { 'project': project } )