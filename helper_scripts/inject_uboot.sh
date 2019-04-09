#!/bin/bash

set -e

LOOP_DEVICE=$1
UBOOT=$2

if test -z "$LOOP_DEVICE"
then
	echo "Loop device must be passed as first argument"
	exit -1
fi

if test -z "$UBOOT"
then
	echo "Path to U-Boot must be passed as second argument"
	exit -1
fi

sudo dd if=$UBOOT of=$LOOP_DEVICE bs=1k seek=1
