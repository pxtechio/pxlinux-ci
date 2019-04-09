#!/bin/bash

#Exit on any error
set -e

#Install updated packages and remove any artifacts
pacman -Syu --noconfirm
pacman -Scc --noconfirm

#Sleep for 3sec to allow for all processes to end.
sleep 3
