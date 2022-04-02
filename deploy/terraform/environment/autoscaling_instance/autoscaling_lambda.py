# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



import os
import boto3
import logging



def getInstanceIds( autoScalingGroupName ):
	autoscaling = boto3.client( 'autoscaling' )
	
	response = autoscaling.describe_auto_scaling_groups( AutoScalingGroupNames = [ autoScalingGroupName ] )
	
	return [ instance['InstanceId'] for instance in response['AutoScalingGroups'][0]['Instances'] if instance['LifecycleState'] == 'InService' ]



def getPrivateIps( instanceIds ):
	ec2 = boto3.client( 'ec2' )
	
	response = ec2.describe_instances( InstanceIds = instanceIds )
	
	return [ reservation['Instances'][0]['PrivateIpAddress'] for reservation in response['Reservations'] ]



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
	logging.getLogger().setLevel( logging.INFO )
	
	# Env vars from Terraform.
	hostedZoneId = os.environ['hostedZoneId']
	recordName = os.environ['recordName']
	recordType = os.environ['recordType']
	recordTtl = int( os.environ['recordTtl'] )
	
	functionName = context.function_name
	eventName = event['detail-type']
	autoScalingGroupName = event['detail']['AutoScalingGroupName']
	
	logging.info( f'Started function "{functionName}" in response to event "{eventName}".' )
	
	instanceIds = getInstanceIds( autoScalingGroupName )
	logging.info( f'Instances: {instanceIds}' )
	
	ips = getPrivateIps( instanceIds ) or [ '0.0.0.0' ]	# Can't have an empty record.
	logging.info( f'Instance ips: {ips}' )
	
	updateDnsRecords( hostedZoneId, recordName, recordType, recordTtl, ips )