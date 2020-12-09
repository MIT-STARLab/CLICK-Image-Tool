#!/bin/bash
# Post buildroot build script, based on:
# buildroot/board/raspberrypi3/post-build.sh
set -u
set -e

# Disable some default boot services from /lib/systemd
declare -a rm_lib_svc=(
    "sysinit.target.wants/dev-hugepages.mount"
    "sysinit.target.wants/sys-fs-fuse-connections.mount"
    "sysinit.target.wants/systemd-ask-password-console.path"
    "sysinit.target.wants/systemd-machine-id-commit.service"
    "sysinit.target.wants/systemd-sysctl.service"
    "sysinit.target.wants/systemd-update-done.service"
    "multi-user.target.wants/systemd-ask-password-wall.path")

for f in "${rm_lib_svc[@]}"; do
    rm -f ${TARGET_DIR}/usr/lib/systemd/system/$f
done

# Disable some default boot services from /etc/systemd
declare -a rm_etc_svc=(
    "ctrl-alt-del.target"
    "sys-fs-fuse-connections.mount"
    "getty@.service"
    "dropbear.service"
    "remote-fs.target"
    "systemd-remount-fs.service"
    "systemd-hwdb-update.service"
    "systemd-timesyncd.service"
    "systemd-resolved.service"
    "systemd-networkd.service"
    "systemd-ask-password-console.path"
    "systemd-machine-id-commit.service")

for f in "${rm_etc_svc[@]}"; do
    rm -f ${TARGET_DIR}/etc/systemd/system/$f
done

# Auto login on root if a UART tty is running
mkdir -p ${TARGET_DIR}/etc/systemd/system/getty.target.wants/
cp ${TARGET_DIR}/usr/lib/systemd/system/serial-getty@.service \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyAMA0.service
sed -i "s/sbin\/agetty -o '-p -- \\\\\\\\u'/sbin\/agetty -a root/" \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyAMA0.service
ln -sfn ../serial-getty@ttyAMA0.service \
    ${TARGET_DIR}/etc/systemd/system/getty.target.wants/serial-getty@ttyAMA0.service

# Delete some extra overhead
rm -rf ${TARGET_DIR}/usr/lib/python3.9/ensurepip/
rm -rf ${TARGET_DIR}/usr/lib/python3.9/site-packages/zmq/tests
rm -rf ${TARGET_DIR}/usr/include/boost/
rm -rf ${TARGET_DIR}/usr/include/openssl/
