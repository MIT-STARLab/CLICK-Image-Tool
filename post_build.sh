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

# Configure the filesystems
if [ -e ${TARGET_DIR}/etc/fstab ] && ! grep -qE '^tmpfs' ${TARGET_DIR}/etc/fstab; then
	# echo "/dev/mmcblk0p3 /root ext4 defaults 0" >> ${TARGET_DIR}/etc/fstab
    # echo "tmpfs /tmp tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /run tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
    echo "tmpfs /var/log tmpfs nosuid,nodev 0 0" >> ${TARGET_DIR}/etc/fstab
fi

# Disable some systemd default services
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-timesyncd.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/getty@.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/remote-fs.target
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/sys-fs-fuse-connections.mount
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-ask-password-console.path 
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-machine-id-commit.service
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/systemd-hwdb-update.service

# Auto login root if a UART tty is running
cp ${TARGET_DIR}/usr/lib/systemd/system/serial-getty@.service \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyAMA0.service
sed -i "s/sbin\/agetty -o '-p -- \\\\\\\\u'/sbin\/agetty -a root/" \
    ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyAMA0.service
