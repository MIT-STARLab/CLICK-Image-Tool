#!/bin/bash
# Main script to build a CLICK golden image

# FSW/FPGA version to use: either a tag or commit hash from CLICK-A-RPi and CLICK-A-FPGA repositories
export FSW_VERSION="b75e6659780a1a31d7e3b60599736d0ed69579de"
export FPGA_VERSION="f9d2ab603b26612674a6ff188968d62685d2ec8f"

# Flag to enable/disable SSH over PPP service on boot
export BOOT_WITH_PPP=1

# Initialization
SECONDS=0
cores=$(nproc)
cores=$((cores+1))
[ ! -d "img" ] && mkdir img
[ ! -d "output" ] && mkdir output
[ ! -f "buildroot/Makefile" ] && git submodule update --init --jobs $cores

# Run buildroot
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_EXTERNAL=../extra BR2_JLEVEL=$cores O=../output
cd ../output
make BR2_JLEVEL=$cores $@

echo "Finished in $((SECONDS/3600))h $(((SECONDS/60)%60))m $((SECONDS%60))s"
