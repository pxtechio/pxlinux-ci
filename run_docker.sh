#/bin/bash


docker run 				\
	--user=root 			\
	-it 				\
	--rm  				\
	--privileged 			\
	-v ~/pxlinux/pxboard/base-5/assets:/assets 	\
	-v ~/pxlinux/pxboard/base-5/config:/config 	\
	pxtech/pxlinux:latest
