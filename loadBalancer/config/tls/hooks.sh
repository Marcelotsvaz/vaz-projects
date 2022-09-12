#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



deploy_challenge() {
	local DOMAIN="${1}" TOKEN_VALUE="${3}"
	
	changeBatch='{"Changes":[{"Action":"CREATE","ResourceRecordSet":{"Name":"_acme-challenge.'${DOMAIN}'","Type":"TXT","TTL":10,"ResourceRecords":[{"Value":"\"'${TOKEN_VALUE}'\""}]}}]}'
	requestId=$(aws route53 change-resource-record-sets	\
		--hosted-zone-id ${hostedZoneId}				\
		--change-batch ${changeBatch}					\
		--query 'ChangeInfo.Id'							\
		--output text)
	aws route53 wait resource-record-sets-changed --id ${requestId}
}


clean_challenge() {
	local DOMAIN="${1}" TOKEN_VALUE="${3}"
	
	changeBatch='{"Changes":[{"Action":"DELETE","ResourceRecordSet":{"Name":"_acme-challenge.'${DOMAIN}'","Type":"TXT","TTL":10,"ResourceRecords":[{"Value":"\"'${TOKEN_VALUE}'\""}]}}]}'
	aws route53 change-resource-record-sets --hosted-zone-id ${hostedZoneId} --change-batch ${changeBatch}
}


request_failure() {
	local STATUSCODE="${1}" REASON="${2}" REQTYPE="${3}" HEADERS="${4}"
}


HANDLER="${1}"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|request_failure)$ ]]; then
	"${HANDLER}" "$@"
fi