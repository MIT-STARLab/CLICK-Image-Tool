#!/bin/bash
# Main script to build a CLICK golden image

# RPi FSW version to use: either a tag or commit hash from https://github.com/MIT-STARLab/CLICK-A-RPi/
export FSW_VERSION="8d2be79b562217891981c691050d9ae219baa358"

# Flag to enable/disable SSH over PPP service on boot
export BOOT_WITH_PPP=1

# Initialization
cores=$(nproc)
cores=$((cores+1))
[ ! -d "img" ] && mkdir img
[ ! -d "output" ] && mkdir output
[ ! -f "buildroot/Makefile" ] && git submodule update --init --jobs $cores

# Run buildroot
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_EXTERNAL=../extra BR2_JLEVEL=$cores O=../output
cd ../output
make BR2_JLEVEL=$cores $1 all
