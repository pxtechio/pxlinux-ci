#/bin/bash

set -e 

pacman -Sy
pacman -S --noconfirm 		\
	base-devel				\
	arch-install-scripts 	\
	git						\
	sudo
#qemu 					\
#qemu-arch-extra			\
	