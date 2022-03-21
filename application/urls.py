# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



from django.urls import path, include
from django.contrib import admin

from django.conf import settings



urlpatterns = [
	path( '',				include( 'commonApp.urls' ) ),
	path( '',				include( 'siteApp.urls' ) ),
	path( '',				include( 'projectsApp.urls' ) ),
	path( '',				include( 'blogApp.urls' ) ),
	path( 'admin/',			admin.site.urls ),
	path( 'jet/',			include( 'jet.urls', 'jet' ) ),
	path( 'jet/dashboard/',	include( 'jet.dashboard.urls', 'jet-dashboard' ) ),
]

if settings.ENVIRONMENT != 'production':
	# Enable Debug Toolbar.
	import debug_toolbar
	
	urlpatterns.append( path( '__debug__/', include( debug_toolbar.urls ) ) )