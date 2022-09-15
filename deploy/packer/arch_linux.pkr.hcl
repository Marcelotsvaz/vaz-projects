# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable "ami_name" {
	type =  string
	default = "VAZ Projects AMI"
}



variable "playbook" {
	type =  string
	default = "amiPlaybook.yaml"
}



packer {
	required_plugins {
		amazon = {
			version = " >= 1.1.3"
			source = "github.com/hashicorp/amazon"
		}
	}
}



source "amazon-ebssurrogate" "arch_linux" {
	# Builder options.
	#---------------------------------------------------------------------------
	spot_price = 0.01
	spot_instance_types = [
		"t3a.nano",
		"t3a.micro",
		"t3a.small",
	]
	
	region = "sa-east-1"
	subnet_id = "subnet-0171a8aa91d068ed7"
	
	# perInstance.sh file that just add the SSH key.
	user_data = "H4sIAAAAAAAAA+3QwWqDQBAGYM99ii095FAaXe2u5FIISUisGKRpA/VSNrpo1GjY1UI89Nljekqh0FNoC/93mWVmYGdmL5VX6UZUsRzqzLgIq+cydorUZdZ5/GTfU8NyLcfpH9zq85Rxzg1iXWacr9p+eUWIsRMqlmXd6HfRfdf3U/2furk2W63MzbYyN0JnVzLOajLQOruTic0YHZFxb+IsOzGhZTT16PJ5xk45b+Gm813uiqeyyOvQ9wOHBbfJnKdBkU5H3iwq7Zf1nj++hpqsxxEJVZ3LuNFktVoQXx4G5IF8nJ/VHPb/mqJtslptO5m8FfKgf/tAAAAAAAAAAAAAAAAAAAAAAAAAf9QRk0aIXwAoAAA="
	ebs_optimized = true
	
	ssh_agent_auth = true
	ssh_username = "marcelotsvaz"
	ssh_interface = "public_ip"
	ssh_pty = true
	
	# Builder root.
	launch_block_device_mappings {
		device_name = "/dev/xvda"
		volume_size = 5
		delete_on_termination = true
		omit_from_artifact = true
	}
	
	# Image root.
	launch_block_device_mappings {
		device_name = "/dev/xvdf"
		volume_size = 2
		volume_type = "gp3"
		encrypted = true
		delete_on_termination = true
	}
	
	source_ami_filter {
		most_recent = true
		owners = [ "self" ]
		
		filters = {
			name = "VAZ Projects Builder AMI"
		}
	}
	
	run_tags = {
		Name: "${var.ami_name} Builder"
	}
	
	run_volume_tags = {
		Name: "${var.ami_name} Builder Volume"
	}
	
	spot_tags = {
		Name: "${var.ami_name} Builder Spot Request"
	}
	
	
	# AMI options.
	#---------------------------------------------------------------------------
	ami_name = var.ami_name
	ami_virtualization_type = "hvm"
	boot_mode = "uefi"
	ena_support = true
	
	force_deregister = true
	force_delete_snapshot = true
	
	ami_root_device {
		source_device_name = "/dev/xvdf"
		device_name = "/dev/xvda"
	}
	
	tags = {
		Name: var.ami_name
	}
	
	snapshot_tags = {
		Name: "${var.ami_name} Snapshot"
	}
}



build {
	sources = [ "source.amazon-ebssurrogate.arch_linux" ]
	
	provisioner "ansible-local" {
		command = "./sudoAnsiblePlaybook.sh"
		
		playbook_dir = "."
		playbook_file = var.playbook
	}
}