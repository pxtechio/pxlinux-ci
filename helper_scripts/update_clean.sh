#!/bin/bash

#Exit on any error
set -e

#Install updated packages and remove any artifacts
pacman -Sy --noconfirm
pacman-key --init

if [ -f '/skipupdate' ]; then
	rm /skipupdate
else
	pacman -Su --noconfirm
fi

if [ -d '/packages' ]; then
	pkgs=`ls -1 *.pkg.tar.xz 2>/dev/null | wc -l`
	if [ $pkgs != 0 ]; then  
		pacman -U /packages/*pkg.tar.xz --noconfirm --force
	fi 
	
	if [ -f '/packages/pacman_packages.txt' ]; then
		pacman -S --noconfirm - < /packages/pacman_packages.txt
	fi
	rm -r /packages
fi

if [ -d '/update-scripts' ]; then
	for f in /update-scripts/*.sh; do
		sh -x $f
	done
	rm -r /update-scripts
fi


pacman -Scc --noconfirm
#Sleep for 3sec to allow for all processes to end.
sleep 3
