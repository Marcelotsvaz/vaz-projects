#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views


app_name = 'siteApp'

urlpatterns = [
	path( '',							views.Home.as_view(),		name = 'home' ),
	path( 'about-me',					views.About_me.as_view(),	name = 'about_me' ),
	path( 'search',						views.Search.as_view(),		name = 'search' ),
	path( 'search/page/<int:page>',		views.Search.as_view(),		name = 'search' ),
	path( 'sitemap.xml',				views.Sitemap.as_view(),	name = 'sitemap' ),
]