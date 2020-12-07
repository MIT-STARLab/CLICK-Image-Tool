#!/bin/bash
# Post buildroot build script, based on:
# buildroot/board/raspberrypi3/post-build.sh
set -u
set -e

# Disable some systemd default services
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-timesyncd.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-resolved.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/getty@.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/remote-fs.target
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-remount-fs.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/sys-fs-fuse-connections.mount
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-ask-password-console.service 
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-machine-id-commit.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-hwdb-update.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-tmpfiles-setup.service

# Auto login root if a UART tty is running
cp ${TARGET_DIR}/usr/lib/systemd/system/serial-getty@.service \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyAMA0.service
sed -i "s/sbin\/agetty -o '-p -- \\\\\\\\u'/sbin\/agetty -a root/" \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyAMA0.service
