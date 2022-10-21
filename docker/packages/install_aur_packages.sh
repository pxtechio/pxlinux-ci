#/bin/bash

set -e

WORKSPACE=$(dirname $0)


#zerofree
cd /packages/zerofree-1.1.1
make
chown build:build zerofree
chmod +x zerofree
mv zerofree /usr/bin

cd $WORKSPACE
