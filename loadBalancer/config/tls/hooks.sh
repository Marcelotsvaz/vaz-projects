#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



set -e	# Abort on error.



function dns_update
{
	local action=${1}; shift
	local changeBatch='{ "Changes": [] }'
	
	while [[ "${@}" ]]; do
		local domain=${1} tokenValue=${3}; shift 3
		
		change=$(cat <<- EOF
			{
				"Action": "${action}",
				"ResourceRecordSet": {
					"Name": "_acme-challenge.${domain}",
					"Type": "TXT",
					"TTL": 10,
					"ResourceRecords": [
						{
							"Value": "\"${tokenValue}\""
						}
					]
				}
			}
		EOF
		)
		
		changeBatch=$(echo ${changeBatch} | jq ".Changes += [ ${change} ]")
	done
	
	local requestId=$(aws route53 change-resource-record-sets	\
		--hosted-zone-id ${hostedZoneId}						\
		--change-batch "${changeBatch}"							\
		--query 'ChangeInfo.Id'									\
		--output text)
	aws route53 wait resource-record-sets-changed --id ${requestId}
}


function deploy_challenge
{
	dns_update CREATE "${@}"
}


function clean_challenge
{
	dns_update DELETE "${@}"
}


command=${1}; shift
if [[ "${command}" =~ ^(deploy_challenge|clean_challenge)$ ]]; then
	${command} "${@}"
fi