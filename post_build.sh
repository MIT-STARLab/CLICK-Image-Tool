#!/bin/bash
# Post buildroot build script, inspired by:
# buildroot/board/raspberrypi3/post-build.sh
# This configures the OS before packaging by buildroot
set -u
set -e

# Disable some default systemd services at /lib/
declare -a rm_lib_svc=(
    "sysinit.target.wants/dev-hugepages.mount"
    "sysinit.target.wants/sys-fs-fuse-connections.mount"
    "sysinit.target.wants/systemd-ask-password-console.path"
    "sysinit.target.wants/systemd-machine-id-commit.service"
    "sysinit.target.wants/systemd-sysctl.service"
    "sysinit.target.wants/systemd-update-done.service"
    "multi-user.target.wants/systemd-ask-password-wall.path"
    "multi-user.target.wants/systemd-user-sessions.service"
    "timers.target.wants/systemd-tmpfiles-clean.timer")

for f in "${rm_lib_svc[@]}"; do
    rm -f ${TARGET_DIR}/usr/lib/systemd/system/$f
done

# Disable some default systemd services at /etc/
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
    "systemd-machine-id-commit.service"
    "getty.target.wants/getty@tty1.service"
    "multi-user.target.wants/dropbear.service"
    "multi-user.target.wants/remote-fs.target"
    "multi-user.target.wants/systemd-networkd.service"
    "multi-user.target.wants/systemd-resolved.service"
    "default.target.wants/e2scrub_reap.service"
    "timers.target.wants/e2scrub_all.timer"
    "network-online.target.wants/systemd-networkd-wait-online.service")

for f in "${rm_etc_svc[@]}"; do
    rm -f ${TARGET_DIR}/etc/systemd/system/$f
done

# Auto login on root if a UART1 debug tty is running
cp ${TARGET_DIR}/usr/lib/systemd/system/serial-getty@.service \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyS0.service
sed -i "s/\[Service\]/# Only run if UART1 is up\nConditionPathExists=\/dev\/ttyS0\n\n\[Service\]/" \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyS0.service
sed -i "s/sbin\/agetty -o '-p -- \\\\\\\\u'/sbin\/agetty -a root/" \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyS0.service
ln -sfn ../serial-getty@ttyS0.service \
    ${TARGET_DIR}/etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service

# Delete some extra overhead
rm -rf ${TARGET_DIR}/usr/lib/python2.7/ensurepip
rm -rf ${TARGET_DIR}/usr/lib/python2.7/site-packages/zmq/tests
