#!/bin/bash
# Main script to build a CLICK golden image

# Initialization
cores=$(nproc)
if [ ! -d "output" ] && mkdir output
git submodule update --recursive --remote --init --jobs $cores

# Run buildroot
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_EXTERNAL=../extras BR2_JLEVEL=$cores O=../output
cd ../output
# make BR2_JLEVEL=$cores