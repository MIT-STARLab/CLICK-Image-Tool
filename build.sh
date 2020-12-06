#!/bin/bash
# Main script to build a CLICK golden image

# Initialization
cores=$(nproc)
git submodule update --remote --rebase --init --jobs $cores
[ ! -d "output" ] && mkdir output
[ ! -L "overlay/root" ] && ln -s "$(pwd)/click" overlay/root

# Run buildroot
# cd buildroot
# make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_EXTERNAL=../extra BR2_JLEVEL=$cores O=../output
# cd ../output
# make BR2_JLEVEL=$cores
