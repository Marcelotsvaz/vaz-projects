#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Debug
########################################
DEBUG_TOOLBAR_CONFIG = {
	'SHOW_TOOLBAR_CALLBACK': 'commonApp.misc.showDebugToolbar',
}


# Apps
########################################
INSTALLED_APPS += [
	'debug_toolbar',
]


# Middleware
########################################
MIDDLEWARE.insert( 0, 'debug_toolbar.middleware.DebugToolbarMiddleware' )