#!/bin/bash
# Post buildroot build script, based on:
# buildroot/board/raspberrypi3/post-build.sh
set -u
set -e

# Move some system files to tmpfs
if [ ! -L ${TARGET_DIR}/var/lock ]; then
    rm -rf ${TARGET_DIR}/run/dbus
    rm -rf ${TARGET_DIR}/var/log/journal
    ln -s /tmp ${TARGET_DIR}/var/spool
    ln -s /tmp ${TARGET_DIR}/var/lock
fi

# Configure the filesystems
if [ -e ${TARGET_DIR}/etc/fstab ] && [ ! grep -qE '^tmpfs' ${TARGET_DIR}/etc/fstab ]; then
	# echo "/dev/mmcblk0p3 /root ext4 defaults 0 1" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /tmp tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /run tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /var/log tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /var/tmp tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
fi
