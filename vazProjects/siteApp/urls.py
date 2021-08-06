#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views


app_name = 'siteApp'

urlpatterns = [
	path( '',				views.home,			name = 'home' ),
	path( 'professional',	views.professional,	name = 'professional' ),
	path( 'about-me',		views.about_me,		name = 'about_me' ),
	path( 'sitemap.xml',	views.sitemap,		name = 'sitemap' ),
]