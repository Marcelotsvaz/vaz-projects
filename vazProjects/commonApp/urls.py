#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views


app_name = 'commonApp'

urlpatterns = [
	path( 'robots.txt',		views.robots,	name = 'robots' ),
	path( 'favicon.ico',	views.favicon,	name = 'favicon' ),
]