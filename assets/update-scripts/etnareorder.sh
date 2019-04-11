#!/bin/bash

cp /update-scripts/etnareorder /bin/etnareorder
cp /update-scripts/pixieEtnaReorder.service /lib/systemd/system/pixieEtnaReorder.service
systemctl enable pixieEtnaReorder.service
