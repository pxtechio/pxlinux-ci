from menci/archlinuxarm:base-devel

COPY packages /packages
COPY build_targets.py /build_targets.py

RUN sh -x /packages/install_pacman_pkgs.sh

RUN useradd -m -s /bin/bash -d /build build
RUN echo "build ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN sh -x /packages/install_aur_packages.sh

COPY helper_scripts /helper_scripts
CMD python /build_targets.py --config=config/targets.yaml
