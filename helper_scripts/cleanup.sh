#!/bin/bash

#Exit on any error
set -e

#Unmount image mounted as loop device:
LOOP_DEVICE=$1
TARGET_IMAGE=$2

if test -z "$LOOP_DEVICE"
then
	echo "Loop device must be passed as first argument"
	exit -1
fi

if test -z "$TARGET_IMAGE"
then
	echo "Path to target image must be passed as second argument"
	exit -1
fi

partx -d $LOOP_DEVICE
losetup -d $LOOP_DEVICE

rm $TARGET_IMAGE