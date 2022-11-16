# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.views.generic import ListView, DetailView
from django.shortcuts import get_object_or_404

from .models import Project



class Projects( ListView ):
	'''
	Projects view.
	'''
	
	model = Project
	template_name = 'projectsApp/projects.html'
	context_object_name = 'projects'


class ProjectView( DetailView ):
	'''
	Project view.
	'''
	
	model = Project
	template_name = 'projectsApp/project.html'
	context_object_name = 'project'
	
	
	def get_queryset( self ):
		# Hide drafts unless user is staff.
		if self.request.user.is_staff:
			return Project.all_objects.all()
		else:
			return super().get_queryset()
	
	def get_context_data( self, **kwargs ):
		context = super().get_context_data( **kwargs )
		
		# Hide page drafts unless user is staff.
		if self.request.user.is_staff:
			context['pages'] = self.object.all_pages.all()
		else:
			context['pages'] = self.object.pages.all()
		
		return context


class PageView( ProjectView ):
	'''
	Project Page view.
	'''
	
	template_name = 'projectsApp/page.html'
	
	
	def get_context_data( self, **kwargs ):
		context = super().get_context_data( **kwargs )
		
		context['currentPage'] = get_object_or_404( context['pages'], number = self.kwargs['page_number'] )
		
		return context