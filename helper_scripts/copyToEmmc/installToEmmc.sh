#!/bin/bash

# ----------------------------------------------
#  burn_image()
#  Copies the file.img into the eMMC memory 
#  chip.
# ----------------------------------------------
burn_image() {

echo "Do you want to burn the eMMC (Type yes)"
read -p "Continue? " inputYes

if [ "$inputYes" == "yes" ]
then
	echo "Copying image"
	dd if=imagenEmmc.img of=/dev/mmcblk1 bs=1M status=progress
else
	echo "Not copying, exiting"
	exit 1
fi

# mount the partitions
mount /dev/mmcblk1p1 /mnt/emmc
mount /dev/mmcblk1p2 /mnt/emmc2

if [ -f /mnt/emmc/imx6qp-pixiepro-bea.dtb ]; then
        cd /mnt/emmc/
        if md5sum --status -c /home/pixiepro/programPixie/imx6qp-pixiepro-bea.dtb.md5; then
                echo "eMMC Partition 1 OK"
        else
                echo "eMMC Partition 1 NOT OK. Exiting"
		umount /dev/mmcblk1p1 
		umount /dev/mmcblk1p2 
                exit 1
        fi
fi

if [ -f /mnt/emmc2/etc/locale.gen ]; then
        cd /mnt/emmc2/etc/
        if  md5sum --status -c /home/pixiepro/programPixie/locale.gen.md5 ; then
                echo "eMMC Partition 2 OK"
        else
                echo "eMMC Partition 2 NOT OK. Exiting"
		umount /dev/mmcblk1p1 
		umount /dev/mmcblk1p2 
                exit 1
        fi
else
        echo "File not found. FAILED. Exiting"
		umount /dev/mmcblk1p1 
		umount /dev/mmcblk1p2 
        exit 1
fi

cd /home/pixiepro/programPixie/

umount /dev/mmcblk1p1 
umount /dev/mmcblk1p2 

}

# ----------------------------------------------
#  burn_fuses()
#  Burn the fuses of the current pixieboard
# ----------------------------------------------
burn_fuses(){

echo "Do you want to burn the fuses? WARNING: This is irreversible"

read -p "Continue? " inputYes

if [ "$inputYes" != "yes" ]
then
	echo "Not burning, exiting"
	exit 1	
fi

echo "Are you sure? WARNING: This wont allow Pixie to boot from SD ever again"

read -p "Continue? " inputYes

if [ "$inputYes" == "yes" ]
then
	echo "Burning fuses"
	echo "0x00000010" > /sys/fsl_otp/HW_OCOTP_CFG5
	echo "0x58002862" > /sys/fsl_otp/HW_OCOTP_CFG4
else
	echo "Not burning, exiting"
	exit 1	
fi

echo "Reboot?"

read -p "Continue? " inputYes

if [ "$inputYes" == "yes" ]
then
	echo "Rebooting"
	reboot
else
	echo "Not rebooting, exiting"
	exit 1	
fi

}

# ----------------------------------------------
#  copy_sd()
#  Copy the SD image into the eMMC memory.
# ----------------------------------------------
copy_sd(){

sys_clone_path="/usr/local/sbin/sys-clone"
mmcblk1_path="/dev/mmcblk1"

echo "Copy the SD card image into the eMMC memory"

if [ -e "$sys_clone_path" ]
then
	if [ -b "$mmcblk1_path" ]
	then
		(echo "y"; echo ;) | sys-clone -f -v -e mmcblk2p /dev/mmcblk1
	else
		echo "Insert SD card into the secondary slot"
		exit
	fi
else
	echo "Not binary found.
	Install it from https://github.com/billw2/rpi-clone.git"
fi

echo "Copy the u-boot.imx file into the eMMC memory"

dd if=u-boot-dtb.imx-EMMCBOOT of=/dev/mmcblk1 bs=1k seek=1 && sync

echo "Edit the fstab file to boot from the eMMC memory"

# Mount each partition to edit the /etc/fstab file
# and to copy the boot.txt and boot.scr files

mount /dev/mmcblk1p2 /mnt
mount /dev/mmcblk1p1 /mnt/boot

cp fstab /mnt/etc/
cp boot.txt boot.scr /mnt/boot/

umount /mnt/boot
umount /mnt/

}

# ----------------------------------------------
#  usage()
#  Show the usage information for this script
# ----------------------------------------------
usage() {

echo -n "This script will copy the image to the eMMC, burn the fuses and 
reboot. please run as root

Usage:	./$(basename "$0") {-b|--burn} {-c|--copy-sd} {-f|--fuses}

	-b, --burn	- burn the image locate in /home/pixiepro/programPixie/
	-c, --copy-sd	- copy the image that is in the SD card into the eMMC
	-f, --fuses	- burn the fuses in the current pixieboard
	-h, --help	- show the help information.
"
}

# =====================================
# 	Command line
# =====================================
while [ "$1" ]
do
	case "$1" in
		-b|--burn)
			burn_image
			;;
		-c|--copy-sd)
			copy_sd
			;;
		-f|--fuses)
			burn_fuses
			;;
		-h|--help)
			usage
			;;
		*)
			echo "Error: '$1' Argument not valid"
			usage >&2
			;;
	esac
	shift
done







