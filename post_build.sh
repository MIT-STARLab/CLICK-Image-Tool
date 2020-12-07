#!/bin/bash
# Post buildroot build script, based on:
# buildroot/board/raspberrypi3/post-build.sh
set -u
set -e

# Move some system files to tmpfs
rm -rf ${TARGET_DIR}/run/dbus
rm -rf ${TARGET_DIR}/var/log/journal
ln -sfn /tmp ${TARGET_DIR}/var/spool
ln -sfn /tmp ${TARGET_DIR}/var/lock
ln -sfn /tmp ${TARGET_DIR}/var/tmp

# Disable some systemd default services
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-timesyncd.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/getty@.service

# Auto login root if a tty running
sed -i "s/sbin\/agetty/sbin\/agetty -a root/" ${TARGET_DIR}/usr/lib/systemd/system/serial-getty@.service

# Configure the filesystems
if [ -e ${TARGET_DIR}/etc/fstab ] && ! grep -qE '^tmpfs' ${TARGET_DIR}/etc/fstab; then
	# echo "/dev/mmcblk0p3 /root ext4 defaults 0" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /tmp tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /run tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /var/log tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
fi
