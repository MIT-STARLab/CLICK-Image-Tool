#!/bin/bash
# Main script to build a CLICK golden image

# FSW/FPGA version to use: either a tag or commit hash from CLICK-A-RPi and CLICK-A-FPGA repositories
export FSW_VERSION="0ed734eb291e00325eaec2f934c627244ac1d70d"
export FPGA_VERSION="4d3ee51ad61fdb75c394776933acc27c770881dd"
export FPGA_DEFAULT="protected_output_6_stall_spi_1.xsvf"

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
