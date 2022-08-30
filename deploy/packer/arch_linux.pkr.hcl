# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



locals {
	ami_name = "Arch Linux AMI"
	mount_point = "/mnt/new"
	env = {
		mountPoint = local.mount_point
		disk = "/dev/nvme1n1"
	}
}



packer {
	required_plugins {
		amazon = {
			version = ">= 1.1.3"
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
	
	ebs_optimized = true
	user_data_file = "ssh.tar.gz"
	
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
			name = "Arch Linux AMI Builder AMI"
		}
	}
	
	run_tags = {
		Name: "${local.ami_name} Builder"
	}
	
	run_volume_tags = {
		Name: "${local.ami_name} Builder Volume"
	}
	
	spot_tags = {
		Name: "${local.ami_name} Builder Spot Request"
	}
	
	
	# AMI options.
	#---------------------------------------------------------------------------
	ami_name = local.ami_name
	ami_virtualization_type = "hvm"
	ena_support = true
	
	ami_root_device {
		source_device_name = "/dev/xvdf"
		device_name = "/dev/xvda"
	}
	
	tags = {
		Name: local.ami_name
	}
	
	snapshot_tags = {
		Name: "${local.ami_name} Snapshot"
	}
}



build {
	sources = [ "source.amazon-ebssurrogate.arch_linux" ]
	
	provisioner "shell" {
		execute_command = "sudo {{.Vars}} {{.Path}}"
		
		env = local.env
		
		scripts = [
			"scripts/pre.sh"
		]
	}
	
	provisioner "shell" {
		execute_command = "sudo cp {{.Path}} ${local.mount_point} && sudo {{.Vars}} arch-chroot ${local.mount_point} /{{split .Path \"/\" 2}}"
		remote_file = "script.sh"
		
		env = local.env
		
		scripts = [
			"scripts/chroot.sh"
		]
	}
	
	provisioner "shell" {
		inline = [
			"sudo rm ${local.mount_point}/script.sh"
		]
	}
	
	provisioner "shell" {
		execute_command = "sudo {{.Vars}} {{.Path}}"
		
		env = local.env
		
		scripts = [
			"scripts/pos.sh"
		]
	}
}