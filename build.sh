#!/bin/bash
# Main script to build a CLICK golden image

# FSW/FPGA version to use: either a tag or commit hash from CLICK-A-RPi and CLICK-A-FPGA repositories
export FSW_VERSION="ae06eacb2b63ec3e20b6e84f4052dc26bcd03113"
export FPGA_VERSION="f4d4c91b9316a8a19e6ade24b6411af6603078e6"

# Flag to enable/disable SSH over PPP service on boot
export BOOT_WITH_PPP=1

# Initialization
SECONDS=0
cores=$(nproc)
cores=$((cores+1))
[ ! -d "bin" ] && mkdir bin
[ ! -d "img" ] && mkdir img
[ ! -d "output" ] && mkdir output
[ ! -f "buildroot/Makefile" ] && git submodule update --init --jobs $cores

# Run buildroot
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_EXTERNAL=../extra BR2_JLEVEL=$cores O=../output
cd ../output
make BR2_JLEVEL=$cores $@

echo "Finished in $((SECONDS/3600))h $(((SECONDS/60)%60))m $((SECONDS%60))s"
