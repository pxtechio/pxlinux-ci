#!/bin/bash

set -e

BASE_IMG=
MNT_DIR=
TARGET_NAME=
UBOOT=
ROOTFS=
PACKAGES=
SCRIPTS=
SKIP_UPDATE=

for i in "$@"
do
	case $i in
	    -b=*|--BaseImage=*)
	    BASE_IMG="${i#*=}"
	    shift # past argument=value
	    ;;
	    -m=*|--MountDir=*)
	    MNT_DIR="${i#*=}"
	    shift # past argument=value
	    ;;
	    -t=*|--TargetImage=*)
	    TARGET_NAME="${i#*=}"
	    shift # past argument=value
	    ;;
	    -u=*|--U-Boot=*)
	    UBOOT="${i#*=}"
	    shift # past argument=value
	    ;;
	    -f=*|--RootFS=*)
	    ROOTFS="${i#*=}"
	    shift # past argument=value
	    ;;
	    -p=*|--Packages=*)
	    PACKAGES="${i#*=}"
	    shift # past argument=value
	    ;;
	    -s=*|--Scripts=*)
	    SCRIPTS="${i#*=}"
	    shift # past argument=value
	    ;;
	    -k=*|--SkipUpdate=*)
	    SKIP_UPDATE="${i#*=}"
	    shift # past argument=value
	    ;;
	    *)
	          # unknown option
	    ;;
	esac
done


if test -z "$BASE_IMG"
then
	echo "Path to base image file must be passed as --BaseImage."
	exit -1
fi

if test -z "$MNT_DIR"
then
	MNT_DIR=mnt
fi

if test -z "$TARGET_NAME"
then
	echo "Name of final image must be passed as --TargetImage."
	exit -1
fi


SRC_DIR=$(dirname $0)
TARGET_DIR=$(dirname $TARGET_NAME)
TARGET_IMG="$TARGET_DIR/target.img"

echo
echo "===================STEP 1: CREATE TARGET IMAGE===================="
sh $SRC_DIR/create_target_img.sh $BASE_IMG $TARGET_IMG

echo
echo "===================STEP 2: MOUNT LOOP DEVICE======================"
LOOP_DEVICE=$(sh $SRC_DIR/mount_lo.sh $TARGET_IMG | tail -1 | awk '{print $1}' | sed 's/://g')

echo
echo "===================STEP 3: MOUNT TARGET IMAGE====================="
sh -x $SRC_DIR/mount_img.sh $LOOP_DEVICE $MNT_DIR
echo $LOOP_DEVICE "mounted in:" $MNT_DIR

echo
echo "===================STEP 4: COPY FILES======================"
if test -z "$ROOTFS"
then
	echo "No files to copy."
else
	cp -r $ROOTFS/* $MNT_DIR/
	echo "All files copied."
fi

echo
echo "===================STEP 5: COPY PACKAGES========================="
if test -z "$PACKAGES"
then
	echo "No files to copy."
else
	mkdir -p $MNT_DIR/packages
	cp $PACKAGES/* $MNT_DIR/packages
	echo "Package files copied."
fi

echo
echo "===================STEP 6: COPY SCRIPTS========================="
if test -z "$SCRIPTS"
then
	echo "No files to copy."
else
	mkdir -p $MNT_DIR/update-scripts
	cp $SCRIPTS/* $MNT_DIR/update-scripts
	echo "Scripts copied."
fi

echo
echo "===================STEP 7: UPDATE TARGET IMAGE===================="

if test -z "$SKIP_UPDATE"
then
	echo "Pacman update will be performed."
else
	touch $MNT_DIR/skipupdate
	echo "Pacman update will NOT be performed."
fi

sh $SRC_DIR/update_img.sh $MNT_DIR
sh $SRC_DIR/umount_img.sh $MNT_DIR
echo "Target image updated successfully"

echo
echo "===================STEP 8: INJECT U-BOOT=========================="
if test -z "$UBOOT"
then
	echo "No U-Boot file to inject."
else
	sh $SRC_DIR/inject_uboot.sh $LOOP_DEVICE $UBOOT
	echo "U-Boot injected successfully."
fi

echo
echo "===================STEP 9: SHRINK IMAGE==========================="
sh $SRC_DIR/shrink_img.sh $LOOP_DEVICE $TARGET_IMG $TARGET_NAME
echo "Final image output as:" $TARGET_NAME

echo
echo "===================STEP 10: CLEAN UP==============================="
sh $SRC_DIR/cleanup.sh $LOOP_DEVICE $TARGET_IMG
echo "Process completed successfully. Exiting script."
