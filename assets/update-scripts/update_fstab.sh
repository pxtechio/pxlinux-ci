#!/bin/bash

set -e

WORKSPACE=$(dirname $0)

cd /etc
mv fstab fstab.old
cp /update-scripts/fstab .

cd $WORKSPACE