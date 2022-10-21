#!/bin/bash

#Exit on any error
set -e

#Install updated packages and remove any artifacts
pacman -Sy --noconfirm --quiet
pacman-key --init

if [ -f '/skipupdate' ]; then
	rm /skipupdate
else
	pacman -Su --noconfirm --quiet
fi

if [ -d '/packages' ]; then
        echo "Packages directory exists, installing:"
        pkgs=`ls -1 /packages/*.pkg.tar.xz 2>/dev/null | wc -l`
        if [ $pkgs != 0 ]; then
                echo "Installing packages from pkg.tar.xz files"
		yes | pacman -U /packages/*pkg.tar.xz
        fi

        if [ -f '/packages/pacman_packages.txt' ]; then
                echo "Installing packages from pacman_packages.txt"
                pacman -S --noconfirm - < /packages/pacman_packages.txt
        fi

        if [ -f '/packages/remove_packages.txt' ]; then
                echo "Uninstalling packages from remove_packages.txt"
                pacman -R --noconfirm - < /packages/remove_packages.txt
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
systemctl enable pixie-install-config.service
sleep 3
