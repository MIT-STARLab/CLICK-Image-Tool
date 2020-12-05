#!/bin/bash

# submodule update

mkdir -p build
cd buildroot
make defconfig BR2_DEFCONFIG=../config_buildroot.txt O=../build
