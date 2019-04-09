#!/bin/bash

#Exit on any error
set -e

TARGET_IMG=$1

if test -z "$TARGET_IMG"
then
	echo "Path to target image file must be passed as first argument."
	exit -1
fi

#Mount the image as loop device
LOOP_DEVICE=$(losetup -f --show $TARGET_IMG)
ROOT_LO=$(echo $LOOP_DEVICE)p2

#Create a loop device for each partition in $LOOP_DEVICE
partx -a $LOOP_DEVICE

#Check and extend $ROOT_LO file system
fsck -fy $ROOT_LO
resize2fs $ROOT_LO

echo $LOOP_DEVICE

