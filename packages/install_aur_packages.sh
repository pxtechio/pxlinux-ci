#/bin/bash

set -e

WORKSPACE=$(dirname $0)

#binfmt-qemu-static [binary]
cd /tmp
git clone https://aur.archlinux.org/binfmt-qemu-static.git
cd binfmt-qemu-static
makepkg -si --noconfirm

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
