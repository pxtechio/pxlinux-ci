# pxlinux-ci
CI Environment for building PX:Linux Images.

## About PX:Linux

[PX: Linux](https://www.pxtech.io) is a Linux Distribution for Industrial IoT system based on [Arch Linux ARM](https://archlinuxarm.org/).

PX:Linux is part of PX:Tech, an End-to-End platform for building Industrial IoT systems including:
- [PX:Board](https://www.pxtech.io/pxboard/index.html) A production ready Single Board Computer enabled with LTE 4G.
- [PX:Linux](https://www.pxtech.io/pxboard/index.html) A Linux distribution for Industrial IoT systems.
- [PX:Cloud](https://www.pxtech.io) A cloud-based platform that allows for effective IoT fleet management.

## Building the Docker image

You can download a prebuilt docker image from [Docker Hub](https://cloud.docker.com/u/pxtech/repository/docker/pxtech/pxlinux-ci). To pull the image simply run:
```
docker pull pxtech/pxlinux-ci
```

To build it yourself, clone this [Github repository](https://github.com/pxtechio/pxlinux-ci) and run the build command:

```

docker build .
```

## Preparing the run

### Dependencies

Your host machine must have qemu-user-static installed and the interpreter correctly registered to binfmt_misc .
If you are running Arch Linux, you can install this package from the AUR.


Before running the image, make sure you have a valid config/targets.yaml file. You can specify more than one target.
### Mandatory tags
#### Targets
- **Name**: Name of your target.
- **TargetImage**: Name of the file that will be created.
- **SkipUpdate**: Boolean value. Make true if you want to skip package updates.
- **Assets/BaseImage**: Path to base image that will be updated.

#### Commands
Currently, only build command is supported:
BuildCommand:
  cmd: helper_scripts/build_img.sh
  params:
    - BaseImage
    - TargetImage
    - U-Boot
    - RootFS
    - DeviceTrees
    - Packages
    - Scripts
    
### Optional
- **Assets/U-Boot**: Path to custom U-Boot file. This will be injected from sector 1.
- **Assets/DeviceTrees**: Path to .dtb files that will be copied to /boot directory. Symlinks are NOT updated by this stage.
- **Assets/RootFS**: Directory structure in this path is copied to '/'. Destination can't be symlink.
- **Assets/Packages**: Path to packages that will be installed as part of the new image. A pacman_packages.txt can be provided to install from configured pacman repos.
- **Assets/Scripts**: Path to custom scripts to modify base image. This stage can perform updates to services, fstab, bootscript, etc.

### Minumal config
A minimal targets.yaml file is provided as part of this project and looks like this:
```
Targets:
  PXBoardQP4G:
    Name: PXBoardQP4G
    TargetImage: assets/images/PXBoardQP4G-latest.img
    SkipUpdate: False
    Assets:
      BaseImage:
        path: assets/images/PixieQP4GCoreImage-2018-11-13.img
        url: https://code-ing.com/pixierepo/release/images/latest/PixieQP4GCoreImage.zip

BuildCommand:
  cmd: helper_scripts/build_img.sh
  params:
    - BaseImage
    - TargetImage
    - U-Boot
    - DeviceTrees
    - Packages
    - Scripts
```

## Running
Container must run privileged because it needs to create and use loopback devices to mount and modify the .img files.
Directories containing 'assets' and 'config' must be mounted as volumes. Assuming this project exists in your home directory, you can start the build process as:

```
docker run 				\
	--user=root 			\
	-it 				\
	--rm 				\
	--privileged 			\
	-v ~/pxlinux-ci/assets:/assets 		\
	-v ~/pxlinux-ci/config:/config 		  \
	pxtech/pxlinux-ci:latest
```

## Contribute
If you're interested in adding features or contributing to PX:Linux or PX:Tech, contact the maintainers of this repository.

