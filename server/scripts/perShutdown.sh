#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



echo 'Starting Shutdown Script...'



# Backup
#---------------------------------------
/home/${user}/server/config/backup.sh


# Route53 Clean Up
#---------------------------------------
ipv4Change='{"Action":"UPSERT","ResourceRecordSet":{"Name":"'${hostname}'","Type":"A","TTL":60,"ResourceRecords":[{"Value":"0.0.0.0"}]}}'
ipv6Change='{"Action":"UPSERT","ResourceRecordSet":{"Name":"'${hostname}'","Type":"AAAA","TTL":60,"ResourceRecords":[{"Value":"::"}]}}'
aws route53 change-resource-record-sets	\
	--hosted-zone-id ${hostedZoneId}	\
	--change-batch '{ "Changes": [ '${ipv4Change}', '${ipv6Change}' ] }'



echo 'Finished Shutdown Script.'