#!/bin/bash

#Exit on any error
set -e

#Unmount image mounted as loop device:
LOOP_DEVICE=$1
partx -d $LOOP_DEVICE
losetup -d $LOOP_DEVICE

