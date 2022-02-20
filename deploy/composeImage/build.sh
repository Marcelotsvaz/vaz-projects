#!/bin/bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



imageName='registry.gitlab.com/marcelotsvaz/vaz-projects/compose:2.2'

docker build --pull --tag ${imageName} --push .