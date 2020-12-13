#!/bin/bash
# Main script to build a CLICK golden image

# Flag to enable/disable SSH over PPP on boot
export BOOT_WITH_PPP=1

# Initialization
cores=$(nproc)
cores=$((cores+1))
[ ! -d "output" ] && mkdir output
[ ! -f "buildroot/Makefile" ] && git submodule update --init --jobs $cores

# Run buildroot
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_EXTERNAL=../extra BR2_JLEVEL=$cores O=../output
cd ../output
make BR2_JLEVEL=$cores $1 all
