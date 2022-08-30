#!/bin/bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



set -ex



# Cleanup
#---------------------------------------
rm ${mountPoint}/etc/machine-id	# Enable systemd ConditionFirstBoot.

umount ${mountPoint}
rm -r ${mountPoint}