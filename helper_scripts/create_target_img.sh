#!/bin/bash

#Exit on any error
set -e

#Create the image, copy base image, resize partition and grow fs.
BASE_IMG=$1
TARGET_IMG=$2
IMG_SIZE=8192

#Check for args
if test -z "$BASE_IMG"
then
	echo "Path to base image file must be passed as first argument."
	exit -1
fi

if test -z "$TARGET_IMG"
then
	echo "Path to target image file must be passed as second argument."
	exit -1
fi

TARGET_DIR=$(dirname $TARGET_IMG)
mkdir -p $TARGET_DIR

#Create 8GB image
dd if=/dev/zero of=$TARGET_IMG bs=1M count=0 seek=$IMG_SIZE 
#Copy base image
dd conv=notrunc if=$BASE_IMG of=$TARGET_IMG bs=64M

#Resize partition and inflate filesystem.
(echo d; echo 2; echo n; echo p; echo 2; echo 139264; echo  ; echo w) | fdisk $TARGET_IMG


