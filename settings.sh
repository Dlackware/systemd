#!/bin/bash

# The following settings is for use if you build everything from source and is a required setting
# SBO_SOURCE=${SBO_SOURCE:-YES}

# Required:
#
# Make sure the /tmp directory is atleast 6GB
# The below line needs to be replaced with a check and add or alter size
#
# /tmp is half your RAM

echo 'tmpfs   /tmp         tmpfs   nodev,nosuid,size=6G          0  0' >> /etc/fstab || exit 1

# Optional:
#
# Allow root login on ssh

echo 'ssh' >> /etc/securetty || exit 1

