#!/bin/bash

set -e

BASE_IMG=$1
MNT_DIR=$2
TARGET_NAME=$3
UBOOT=$4

if test -z "$BASE_IMG"
then
	echo "Path to base image file must be passed as first argument."
	exit -1
fi

if test -z "$MNT_DIR"
then
	echo "Path to mount directory must be passed as second argument."
	exit -1
fi

if test -z "$TARGET_NAME"
then
	echo "Name of final image must be passed as third argument."
	exit -1
fi

if test -z "$UBOOT"
then
	echo "Path to U-Boot must be passed as fourth argument."
	exit -1
fi

SRC_DIR=$(dirname $0)
TARGET_DIR=$(dirname $TARGET_NAME)
TARGET_IMG="TARGET_DIR/target.img"

#Create target image, pass base & target images as arguments
echo
echo "===================STEP 1: CREATE TARGET IMAGE===================="
sh -v $SRC_DIR/create_target_img.sh $BASE_IMG $TARGET_IMG

#Mount target image as loop device
echo
echo "===================STEP 2: MOUNT LOOP DEVICE======================"
LOOP_DEVICE=$(sh -x $SRC_DIR/mount_lo.sh $TARGET_IMG | tail -1)
echo "Image mounted as:" $LOOP_DEVICE

#Mount loop device in MNT_DIR
echo
echo "===================STEP 3: MOUNT TARGET IMAGE====================="
sh -v $SRC_DIR/mount_img.sh $LOOP_DEVICE $MNT_DIR
echo $LOOP_DEVICE "mounted in:" $MNT_DIR

#Update Image
echo
echo "===================STEP 4: UPDATE TARGET IMAGE===================="
sh -v $SRC_DIR/update_img.sh $MNT_DIR
sh -v $SRC_DIR/umount_img.sh $MNT_DIR
echo "Target image updated successfully"

echo
echo "===================STEP 5: INJECT U-BOOT=========================="
sh -v $SRC_DIR/inject_uboot.sh $LOOP_DEVICE $UBOOT
echo "U-Boot injected successfully"

echo
echo "===================STEP 6: SHRINK IMAGE==========================="
sh -v $SRC_DIR/shrink_img.sh $LOOP_DEVICE $TARGET_IMG $TARGET_NAME
echo "Final image output as:" $TARGET_NAME

echo
echo "===================STEP 7: CLEAN UP==============================="
sh -v $SRC_DIR/cleanup.sh $LOOP_DEVICE $TARGET_IMG
echo "Process completed successfully. Exiting script."