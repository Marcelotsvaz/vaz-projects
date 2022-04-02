# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import os
import boto3
import logging



def getInstancePrivateIp( instanceId ):
	ec2 = boto3.client( 'ec2' )
	
	response = ec2.describe_instances( InstanceIds = [ instanceId ] )
	
	return response['Reservations'][0]['Instances'][0]['PrivateIpAddress']



def getDnsRecords( hostedZoneId, recordName, recordType ):
	route53 = boto3.client( 'route53' )
	
	response = route53.list_resource_record_sets(
		HostedZoneId = hostedZoneId,
		StartRecordName = recordName,
		StartRecordType = recordType
	)
	
	return { record['Value'] for record in response['ResourceRecordSets'][0]['ResourceRecords'] }



def updateDnsRecords( hostedZoneId, recordName, recordType, ttl, ips ):
	route53 = boto3.client( 'route53' )
	
	route53.change_resource_record_sets( HostedZoneId = hostedZoneId, ChangeBatch = {
		'Changes': [
			{
				'Action': 'UPSERT',
				'ResourceRecordSet': {
					'Name': recordName,
					'Type': recordType,
					'TTL': ttl,
					'ResourceRecords': [ { 'Value': ip } for ip in ips ]
				}
			}
		]
	})



def main( event, context ):
	# Env vars from Terraform.
	hostedZoneId = os.environ['hostedZoneId']
	recordName = os.environ['recordName']
	recordType = os.environ['recordType']
	recordTtl = int( os.environ['recordTtl'] )
	
	functionName = context.function_name
	eventName = event['detail-type']
	instanceId = event['detail']['EC2InstanceId']
	
	logging.info( f'Started function "{functionName}" in response to event "{eventName}".' )
	
	instancePrivateIp = getInstancePrivateIp( instanceId )
	ips = getDnsRecords( hostedZoneId, recordName, recordType )
	
	if eventName == 'EC2 Instance Launch Successful':
		ips.add( instancePrivateIp )
	elif eventName == 'EC2 Instance Terminate Successful':
		ips.remove( instancePrivateIp )
	else:
		logging.error( f'Invalid event: {eventName}' )
		
		return
	
	# Can't have an empty record.
	if len( ips ) == 0:
		ips.add( '0.0.0.0' )
	else:
		ips.discard( '0.0.0.0' )
	
	logging.info( f'Instance ips: {ips}' )
	
	updateDnsRecords( hostedZoneId, recordName, recordType, recordTtl, ips )