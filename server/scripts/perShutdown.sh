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
mac=$(curl -s http://169.254.169.254/latest/meta-data/mac)
ipv4=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
ipv6=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac}/ipv6s)

ipv4Change='{"Action":"DELETE","ResourceRecordSet":{"Name":"'${hostname}'","Type":"A","TTL":60,"ResourceRecords":[{"Value":"'${ipv4}'"}]}}'
ipv6Change='{"Action":"DELETE","ResourceRecordSet":{"Name":"'${hostname}'","Type":"AAAA","TTL":60,"ResourceRecords":[{"Value":"'${ipv6}'"}]}}'
aws route53 change-resource-record-sets	\
	--hosted-zone-id ${hostedZoneId}	\
	--change-batch '{ "Changes": [ '${ipv4Change}', '${ipv6Change}' ] }'



echo 'Finished Shutdown Script.'