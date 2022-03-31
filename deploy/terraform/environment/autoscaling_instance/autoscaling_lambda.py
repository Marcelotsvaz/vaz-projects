# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# import boto3
# import json



# hookName = "LifecycleHookName"
# asgName = "AutoScalingGroupName"
# instanceId = "EC2InstanceId"


def lambda_handler( event, context ):
	# message = event['detail']
	
	print( event )
	print( event['detail'] )
	
	# if hookName in message and asgName in message:
	# 	life_cycle_hook = message[hookName]
	# 	auto_scaling_group = message[asgName]
	# 	instance_id = message[instanceId]
		
	# 	asg_client = boto3.client( 'autoscaling' )
		
	# 	response = asg_client.complete_lifecycle_action(
	# 		LifecycleHookName = life_cycle_hook,
	# 		AutoScalingGroupName = auto_scaling_group,
	# 		LifecycleActionResult = 'CONTINUE',
	# 		InstanceId = instance_id
	# 	)
		
	# 	if response['ResponseMetadata']['HTTPStatusCode'] == 200:
	# 		pass