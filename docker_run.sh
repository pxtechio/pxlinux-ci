#/bin/bash


docker run 				\
	--user=root 			\
	-it 				\
	--rm 				\
	--privileged 			\
	-v ~/pxlinux/assets:/assets 	\
	-v ~/pxlinux/config:/config 	\
	pxtech/pxlinux:latest
