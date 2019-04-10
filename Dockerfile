from archlinux/base:latest

COPY helper_scripts /pxlinux/helper_scripts
COPY packages /pxlinux/packages
COPY uboot /pxlinux/uboot

RUN sh -x /pxlinux/packages/install_pacman_pkgs.sh

RUN useradd -m -s /bin/bash -d /build build 
RUN echo "build ALL=NOPASSWD: ALL" >> /etc/sudoers
USER build

RUN sh -x /pxlinux/packages/install_aur_packages.sh

USER root
CMD sh -x /pxlinux/helper_scripts/build_img.sh 					\
			/pxlinux/images/PixieQP4GCoreImage-2018-11-13.img 	\
			/pxlinux/mnt 									 	\
			/pxlinux/images/final.img 							\
			/pxlinux/uboot/u-boot-dtb-qp4.imx