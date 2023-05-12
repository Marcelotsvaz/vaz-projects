# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



variable ami_name {
	type =  string
	default = "VAZ Projects AMI"
}

variable playbook {
	type =  string
	default = "amiPlaybook.yaml"
}

variable disk_size {
	type =  number
	default = 2
}



packer {
	required_plugins {
		amazon = {
			source = "github.com/hashicorp/amazon"
			version = " >= 1.1.6"
		}
	}
}



source amazon-ebssurrogate main {
	# Builder options.
	#---------------------------------------------------------------------------
	spot_price = 0.05
	spot_instance_types = [
		"t3.micro",
		"t3.small",
		"t3.medium",
		"t3a.micro",
		"t3a.small",
		"t3a.medium",
	]
	
	user_data_file = "../../deployment/userData.tar.gz"
	ebs_optimized = true
	
	ssh_agent_auth = true
	ssh_username = "marcelotsvaz"
	ssh_interface = "public_ip"
	ssh_pty = true
	
	subnet_filter {
		filters = {
			"tag:Environment": "global"
		}
		random = true
	}
	
	security_group_filter {
		filters = {
			"tag:Name": "VAZ Projects Common Security Group"
			"tag:Environment": "global"
		}
	}
	
	source_ami_filter {
		most_recent = true
		owners = [ "self" ]
		
		filters = {
			name = "VAZ Projects Builder AMI"
		}
	}
	
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
		volume_size = var.disk_size
		volume_type = "gp3"
		encrypted = true
		delete_on_termination = true
	}
	
	run_tags = {
		Name = "${var.ami_name} Builder"
	}
	
	run_volume_tags = {
		Name = "${var.ami_name} Builder Volume"
	}
	
	spot_tags = {
		Name = "${var.ami_name} Builder Spot Request"
	}
	
	
	# AMI options.
	#---------------------------------------------------------------------------
	ami_name = var.ami_name
	ami_virtualization_type = "hvm"
	boot_mode = "uefi"
	# Add UEFI boot entry to File(\linux.efi).
	uefi_data = "QU1aTlVFRkma4sWCAAAAAHj5a7fZ92OC2sQJpUGDbv5FKalFTHBHoFvODp1mgSk3AAIrpAk2OQZHoOOSgS0iBQYf8MrBUvAsJguLFEMMeMUdREQPWO6kAXmQliE2WwB/sh9R"
	ena_support = true
	
	force_deregister = true
	force_delete_snapshot = true
	
	ami_root_device {
		source_device_name = "/dev/xvdf"
		device_name = "/dev/xvda"
	}
	
	tags = {
		Name = var.ami_name
	}
	
	snapshot_tags = {
		Name = "${var.ami_name} Snapshot"
	}
}



build {
	sources = [ "source.amazon-ebssurrogate.main" ]
	
	provisioner ansible-local {
		command = "./sudoAnsiblePlaybook.sh"
		
		playbook_dir = "."
		playbook_file = var.playbook
	}
}