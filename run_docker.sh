#/bin/bash


docker run 				\
	--user=root 			\
	-it 				\
	--rm  -q				\
	--privileged 			\
	-v ~/pxlinux-ci/assets:/assets 	\
	-v ~/pxlinux-ci/config:/config 	\
	pxtech/pxlinux:latest
