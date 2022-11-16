# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views



app_name = 'blogApp'

urlpatterns = [
	path( 'blog',										views.BlogView.as_view(),		name = 'blog' ),
	path( 'blog/page/<int:page>',						views.BlogView.as_view(),		name = 'blog' ),
	path( 'blog/tags/<slug:tag_slug>',					views.BlogByTagView.as_view(),	name = 'blog' ),
	path( 'blog/tags/<slug:tag_slug>/page/<int:page>',	views.BlogByTagView.as_view(),	name = 'blog' ),
	path( 'blog/<slug:slug>',							views.PostView.as_view(),		name = 'post' ),
]