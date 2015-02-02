#!/bin/bash

SBO_SOURCE=${SBO_SOURCE:-YES}

#
# Make sure the /tmp directory is atleast 4GB
# The below line needs to be replaced with a check and add or alter size
#
# /tmp is half your RAM

echo 'tmpfs   /tmp         tmpfs   nodev,nosuid,size=4G          0  0' >> /etc/fstab || exit 1

# echo 'ssh' >> /etc/securetty || exit 1

