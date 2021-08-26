#!/bin/bash
#
# VAZ Projects
#
#
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



source 'deployment/env/bin/activate'



# Load environment variables.
if [[ ${1} = 'staging' ]]; then
	environment='staging'
elif [[ ${1} = 'production' ]]; then
	environment='production'
else
	ERROR
fi
set -a
source "server/scripts/${environment}.sh"
set +a



if [[ ${2} = 'uploadFiles' ]]; then
	# Source upload.
	git archive master |							\
	tar -f - --wildcards --delete '**/static/**' |	\
	zstd -c |										\
	aws s3 cp - s3://${bucket}/${environment}/source.tar.zst

	# Upload static files.
	server/scripts/less.sh
	vazProjects/manage.py collectstatic --ignore */src/* --no-input

	# Invalidade static files cache.
	aws cloudfront create-invalidation --distribution-id ${cloudfrontId} --paths '/*'
	
	
elif [[ ${2} = 'launchInstance' ]]; then
	# Get latest AMI.
	imageId=$(aws ec2 describe-images --filters 'Name=name,Values=Arch Linux AMI' --query 'Images[0].ImageId' --output text)
	
	# TODO: Select region on launch.
	# TODO: Select instance type on launch.
	# Launch spot instance from template.
	userData=$(cd server/scripts/ && tar -cz per*.sh ${environment}.sh --transform="s/${environment}.sh/environment.sh/" | base64 -w 0)
	aws ec2 run-instances											\
		--cli-input-json file://server/scripts/${environment}.json	\
		--user-data ${userData}										\
		--image-id ${imageId}
	
	
elif [[ ${2} = 'terminateInstance' ]]; then
	# Cancel spot instance request.
	requestIds=$(aws ec2 describe-instances								\
		--filter "Name=tag:Name, Values=${instanceName}"				\
		--query 'Reservations[*].Instances[*].SpotInstanceRequestId'	\
		--output text)
	aws ec2 cancel-spot-instance-requests --spot-instance-request-ids ${requestIds}

	# Cancel spot instance.
	instanceIds=$(aws ec2 describe-instances				\
		--filter "Name=tag:Name, Values=${instanceName}"	\
		--query 'Reservations[*].Instances[*].InstanceId'	\
		--output text)
	aws ec2 terminate-instances --instance-ids ${instanceIds}
else
	ERROR
fi