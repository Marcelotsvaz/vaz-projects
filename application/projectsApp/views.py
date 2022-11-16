# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import ListView
from django.shortcuts import render, get_object_or_404

from .models import Project



class Projects( ListView ):
	'''
	Projects view.
	'''
	
	model = Project
	template_name = 'projectsApp/projects.html'
	context_object_name = 'projects'


def project( httpRequest, project_slug ):
	'''
	Project view.
	'''
	
	# Hide drafts unless user is staff.
	if httpRequest.user.is_staff:
		projectQueryset = Project.all_objects
	else:
		projectQueryset = Project.objects
	
	project = get_object_or_404( projectQueryset, slug = project_slug )
	
	if httpRequest.user.is_staff:
		pages = project.all_pages.all()
	else:
		pages = project.pages.all()
	
	return render( httpRequest, 'projectsApp/project.html', { 'project': project, 'pages': pages } )


def page( httpRequest, project_slug, page_number ):
	'''
	Project Page view.
	'''
	
	# Hide drafts unless user is staff.
	if httpRequest.user.is_staff:
		projectQueryset = Project.all_objects
	else:
		projectQueryset = Project.objects
	
	project = get_object_or_404( projectQueryset, slug = project_slug )
	
	if httpRequest.user.is_staff:
		pageQueryset = project.all_pages
	else:
		pageQueryset = project.pages
	
	pages = pageQueryset.all()
	currentPage = get_object_or_404( pageQueryset, number = page_number )
	
	return render( httpRequest, 'projectsApp/page.html', { 'project': project, 'currentPage': currentPage, 'pages': pages } )