#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views


app_name = 'siteApp'

urlpatterns = [
	path( '',				views.home,		name = 'home' ),
	path( 'sitemap.xml',	views.sitemap,	name = 'sitemap' ),
]