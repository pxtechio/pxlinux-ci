#!/bin/bash

set -e

MNT_DIR=$1

if test -z "$MNT_DIR"
then
	echo "Path to mount directory must be passed as first argument"
	exit -1
fi

SRC_DIR=$(dirname $0)

#Copy and execute update script. Clean afterwards.
cp $SRC_DIR/update_clean.sh $MNT_DIR
arch-chroot $MNT_DIR /bin/bash -c "./update_clean.sh"
rm $MNT_DIR/update_clean.sh