from archlinux/base:latest

COPY helper_scripts /pxlinux/helper_scripts
COPY packages /pxlinux/packages
COPY uboot /pxlinux/uboot
COPY build_targets /pxlinux/build_targets

RUN sh -x /pxlinux/packages/install_pacman_pkgs.sh

RUN useradd -m -s /bin/bash -d /build build 
RUN echo "build ALL=NOPASSWD: ALL" >> /etc/sudoers

USER build
RUN sh -x /pxlinux/packages/install_aur_packages.sh

USER root
RUN chmod +x /pxlinux/build_targets
CMD /pxlinux/build_targets