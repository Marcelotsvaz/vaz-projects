#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



include=$(find vazProjects/*App/static/*App/css/src/ -prune)
lessc														\
	--source-map											\
	--include-path="${include///[[:space:]]//:}"			\
	vazProjects/siteApp/static/siteApp/css/src/siteApp.less	\
	deployment/static/siteApp/css/siteApp.css