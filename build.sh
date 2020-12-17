#!/bin/bash
# Main script to build a CLICK golden image

# RPi FSW version to use: either a tag or commit hash from https://github.com/MIT-STARLab/CLICK-A-RPi/
export FSW_VERSION="86de557645abf793d7d05d71ed02b31aa700f3da"

# Flag to enable/disable SSH over PPP service on boot
export BOOT_WITH_PPP=1

# Initialization
cores=$(nproc)
cores=$((cores+1))
[ ! -d "img" ] && mkdir img
[ ! -d "output" ] && mkdir output
[ ! -f "buildroot/Makefile" ] && git submodule update --init --jobs $cores

# Run buildroot
SECONDS=0
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_EXTERNAL=../extra BR2_JLEVEL=$cores O=../output
cd ../output
make BR2_JLEVEL=$cores $@ all
echo "Finished in $((SECONDS/3600))h $(((SECONDS/60)%60))m $((SECONDS%60))s"
