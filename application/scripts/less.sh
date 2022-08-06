#!/bin/bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



include=$(find application/*App/static/*App/css/{,src/} -prune -printf '%p:' | sed 's/:$//')
lessc														\
	--no-color												\
	--source-map											\
	--include-path="${include}"								\
	application/siteApp/static/siteApp/css/src/siteApp.less	\
	deployment/static/siteApp/css/siteApp.css