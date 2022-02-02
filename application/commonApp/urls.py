#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views


app_name = 'commonApp'

urlpatterns = [
	path( 'robots.txt',		views.Robots.as_view(),		name = 'robots' ),
	path( 'favicon.ico',	views.Favicon.as_view(),	name = 'favicon' ),
]