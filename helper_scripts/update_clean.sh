#!/bin/bash

#Exit on any error
set -e

#Install updated packages and remove any artifacts
pacman -Syu --noconfirm
pacman -Scc --noconfirm
