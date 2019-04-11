#!/bin/bash

set -e


WORKSPACE=$(dirname $0)

cd /boot
mv boot.txt boot.txt.old
mv boot.scr boot.scr.old
cp /update-scripts/boot.txt .

cat boot.txt
pacman -S uboot-tools --noconfirm
mkimage -A arm -T script -O linux -C none -d boot.txt boot.scr
pacman -R uboot-tools --noconfirm

#Fix rootfs resizer
cp /update-scripts/resize-rootfs /usr/bin/resize-rootfs
cd $WORKSPACE