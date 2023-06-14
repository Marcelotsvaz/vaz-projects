#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Get root disk and partition.
diskInfo=$(lsblk -nro MOUNTPOINT,PKNAME,PATH,PARTUUID | grep '^/ ')
disk="/dev/$(echo ${diskInfo} | cut -d ' ' -f2)"
partition=$(echo ${diskInfo} | cut -d ' ' -f3)
rootPartitionUuid=$(echo ${diskInfo} | cut -d ' ' -f4)

# Resize root partition.
sgdisk --move-second-header ${disk}
sgdisk --delete 2 ${disk}
sgdisk --new 2:0:0 --change-name 2:Root --partition-guid 2:${rootPartitionUuid} ${disk}

# Reload partitions.
partx -u ${disk}

# Resize filesystem.
resize2fs ${partition}


# Download user data.
mkdir /tmp/deploy/ && cd ${_}
curl -s http://169.254.169.254/latest/user-data | tar -xz
mv per*.sh /usr/local/lib/
test -f environment.env && mv environment.env /etc/environment || true