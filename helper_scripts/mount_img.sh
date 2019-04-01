#!/bin/bash

#Exit script on any error:
set -e

#Mount image from loop device
LOOP_DEVICE=$1
MNT_DIR="./mnt/"
BOOT_MNT_DIR=$(echo $MNT_DIR)"/boot/"
if test -z "$LOOP_DEVICE"
then
	echo "Loop device must be passed as first argument"
	exit -1
fi
BOOT_LO=$(echo $LOOP_DEVICE)p1
ROOT_LO=$(echo $LOOP_DEVICE)p2

mount $ROOT_LO $MNT_DIR
mount $BOOT_LO $BOOT_MNT_DIR

