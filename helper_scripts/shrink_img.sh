#!/bin/bash

set -e

LOOP_DEVICE=$1
TARGET_IMG=$2
TARGET_NAME=$3
BLOCK_DEVICE=/sys/block/$(basename $LOOP_DEVICE)

if test -z "$LOOP_DEVICE"
then
	echo "Loop device must be passed as first argument"
	exit -1
fi

if test -z "$TARGET_IMG"
then
	echo "Target image must be passed as second argument"
	exit -1
fi


if test -z "$TARGET_NAME"
then
	echo "Final image name must be passed as second argument"
	exit -1
fi

BOOT_LO=$(echo $LOOP_DEVICE)p1
ROOT_LO=$(echo $LOOP_DEVICE)p2

fsck -fy $ROOT_LO
resize2fs -M $ROOT_LO
fsck -fy $ROOT_LO

#This is ugly, fix later:
BLOCKS=$(dumpe2fs -h $ROOT_LO | grep "Block count" | awk '{print $3}')
BYTES=$(($BLOCKS*4096)) 
SECTORS=$(($BYTES/512))

partx -d $LOOP_DEVICE
losetup -d $LOOP_DEVICE

(echo d; echo 2; echo n; echo p; echo 2; echo 139264; echo +$SECTORS; echo w)| fdisk $TARGET_IMG

LOOP_DEVICE=$(losetup -f --show $TARGET_IMG)
partx -a $LOOP_DEVICE

fsck -fy $ROOT_LO
zerofree $ROOT_LO

#This is ugly, fix later:
PART_BLOCKS=$(fdisk -l $LOOP_DEVICE | grep $ROOT_LO | awk '{print $3}')
PART_BYTES=$(($PART_BLOCKS*512))
PART_COUNT=$(($PART_BYTES/16777216))
PART_COUNT=$(($PART_COUNT+1))

dd if=$LOOP_DEVICE of=$TARGET_NAME count=$PART_COUNT bs=16M
