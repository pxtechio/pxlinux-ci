#/bin/bash

set -e

WORKSPACE=$(dirname $0)

#qemu-user-static [binary]
cd /tmp
git clone https://aur.archlinux.org/qemu-user-static-bin.git
cd qemu-user-static-bin
makepkg -si --noconfirm


#zerofree
cd /tmp
git clone https://aur.archlinux.org/zerofree.git
cd zerofree
makepkg -si --noconfirm

cd $WORKSPACE