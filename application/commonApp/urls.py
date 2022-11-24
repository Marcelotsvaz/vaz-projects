# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views


app_name = 'commonApp'

urlpatterns = [
	path( 'api/comments-count',	views.CommentsCountApi.as_view(),	name = 'comments_count' ),
	path( 'robots.txt',			views.RobotsView.as_view(),			name = 'robots' ),
	path( 'favicon.ico',		views.FaviconView.as_view(),		name = 'favicon' ),
]