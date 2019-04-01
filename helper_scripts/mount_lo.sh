#!/bin/bash

#Exit on any error
set -e

TARGET_IMG=$1

#Mount the image as loop device
LOOP_DEVICE=$(losetup -f --show $TARGET_IMG)
ROOT_LO=$(echo $LOOP_DEVICE)p2

#Create a loop device for each partition in $LOOP_DEVICE
partx -a $LOOP_DEVICE

#Check and extend $ROOT_LO file system
fsck -l $ROOT_LO
resize2fs $ROOT_LO

echo $LOOP_DEVICE

