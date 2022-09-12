#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



# Grow root partition.
disk="/dev/$(lsblk -nro MOUNTPOINT,PKNAME | grep '^/ ' | cut -d ' ' -f2)"
partition="/dev/$(lsblk -nro MOUNTPOINT,KNAME | grep '^/ ' | cut -d ' ' -f2)"

# Resize root partition.
sgdisk --move-second-header ${disk}
sgdisk --delete 2 ${disk}
sgdisk --new 2:0:0 --change-name 2:'Root' ${disk}

# Reload partitions.
partx -u ${disk}

# Resize filesystem.
resize2fs ${partition}


# Download user data.
mkdir /tmp/deploy && cd ${_}
curl -s http://169.254.169.254/latest/user-data | tar -xz
mv per*.sh /usr/local/lib/
test -f environment.env && mv environment.env /etc/environment || true