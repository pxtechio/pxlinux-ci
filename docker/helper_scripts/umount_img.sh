#!/bin/bash

set -e

MNT_DIR=$1

if test -z "$MNT_DIR"
then
	echo "Path to mount directory must be passed as first argument"
	exit -1
fi

BOOT_MNT_DIR=$MNT_DIR/boot/

#Unmount image
umount $BOOT_MNT_DIR
umount $MNT_DIR
