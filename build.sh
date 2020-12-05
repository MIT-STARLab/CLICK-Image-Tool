#!/bin/bash

cores=$(($(nproc)+1))

# submodule update

mkdir -p build
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt BR2_JLEVEL=$cores O=../build 
