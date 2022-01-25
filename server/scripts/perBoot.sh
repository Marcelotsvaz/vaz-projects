#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



echo 'Starting Boot Script...'



# Route53 Update
#---------------------------------------
mac=$(curl -s http://169.254.169.254/latest/meta-data/mac)
ipv4=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
ipv6=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${mac}/ipv6s)

ipv4Change='{"Action":"CREATE","ResourceRecordSet":{"Name":"'${hostname}'","Type":"A","TTL":60,"ResourceRecords":[{"Value":"'${ipv4}'"}]}}'
ipv6Change='{"Action":"CREATE","ResourceRecordSet":{"Name":"'${hostname}'","Type":"AAAA","TTL":60,"ResourceRecords":[{"Value":"'${ipv6}'"}]}}'
aws route53 change-resource-record-sets	\
	--hosted-zone-id ${hostedZoneId}	\
	--change-batch '{ "Changes": [ '${ipv4Change}', '${ipv6Change}' ] }'



echo 'Finished Boot Script.'