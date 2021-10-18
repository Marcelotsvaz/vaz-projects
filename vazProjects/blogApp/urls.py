#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path

from . import views



app_name = 'blogApp'

urlpatterns = [
	path( 'blog',										views.Blog.as_view(),		name = 'blog' ),
	path( 'blog/page/<int:page>',						views.Blog.as_view(),		name = 'blog' ),
	path( 'blog/tags/<slug:tag_slug>',					views.BlogByTag.as_view(),	name = 'blog' ),
	path( 'blog/tags/<slug:tag_slug>/page/<int:page>',	views.BlogByTag.as_view(),	name = 'blog' ),
	path( 'blog/<slug:slug>',							views.Post.as_view(),		name = 'post' ),
]