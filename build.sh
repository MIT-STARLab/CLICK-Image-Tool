#!/bin/bash
# Main script to build a CLICK golden image

# Initialize
cores=$(($(nproc)+1))
if [ ! -d "output" ] && mkdir output

# Run buildroot
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_EXTERNAL=../extras BR2_JLEVEL=$cores O=../output
cd ../output
make BR2_JLEVEL=$cores