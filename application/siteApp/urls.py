# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views


app_name = 'siteApp'

urlpatterns = [
	path( '',							views.HomeView.as_view(),		name = 'home' ),
	path( 'about-me',					views.AboutMeView.as_view(),	name = 'about_me' ),
	path( 'search',						views.SearchView.as_view(),		name = 'search' ),
	path( 'search/page/<int:page>',		views.SearchView.as_view(),		name = 'search' ),
	path( 'sitemap.xml',				views.SitemapView.as_view(),	name = 'sitemap' ),
]