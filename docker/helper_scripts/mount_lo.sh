#!/bin/bash

#Exit on any error
set -e

TARGET_IMG=$1

if test -z "$TARGET_IMG"
then
	echo "Path to target image file must be passed as first argument."
	exit -1
fi

DEFAULT_LO="/dev/loop0"

#Mount the image as loop device and announce partitions to kernel
if [ ! -e $DEFAULT_LO ]; then mknod $DEFAULT_LO b 7 0; fi
LOOP_DEVICE=$(losetup --find --show --partscan $TARGET_IMG)

echo "Loop device: " $LOOP_DEVICE

#Create a loop device for each partition in $LOOP_DEVICE
PARTITIONS=$(lsblk --raw --output "MAJ:MIN" --noheadings ${LOOP_DEVICE} | tail -n +2)
COUNTER=1
for i in $PARTITIONS; do
    MAJ=$(echo $i | cut -d: -f1)
    MIN=$(echo $i | cut -d: -f2)
    if [ ! -e "${LOOP_DEVICE}p${COUNTER}" ]; then mknod ${LOOP_DEVICE}p${COUNTER} b $MAJ $MIN; fi
    COUNTER=$((COUNTER + 1))
done

ROOT_LO=$(echo $LOOP_DEVICE)p2

#Check and extend $ROOT_LO file system
fsck -fy $ROOT_LO
resize2fs $ROOT_LO

echo $LOOP_DEVICE

