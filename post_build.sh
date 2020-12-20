#!/bin/bash
# Post buildroot build script, inspired by:
# buildroot/board/raspberrypi3/post-build.sh
# This configures the OS before it is packaged by buildroot
set -u
set -e

# Disable console on UART0 (used for PPP/SSH)
ln -sfn /dev/null ${TARGET_DIR}/etc/systemd/system/serial-getty@ttyAMA0.service

# Make dropbear (SSH server) available to user systemd session
cp ${TARGET_DIR}/usr/lib/systemd/system/dropbear.service \
    ${TARGET_DIR}/usr/lib/systemd/user/

# Make PPP/SSH run on boot if configured so (defined in build.sh)
mkdir -p ${TARGET_DIR}/usr/local/fsw/.config/systemd/user/default.target.wants
if [ ${BOOT_WITH_PPP} -eq 1 ]; then
    ln -sfn /usr/lib/systemd/user/ppp.service \
        ${TARGET_DIR}/usr/local/fsw/.config/systemd/user/default.target.wants/ppp.service
else
    rm -f ${TARGET_DIR}/usr/local/fsw/.config/systemd/user/default.target.wants/ppp.service
fi

# Disable some default systemd services from /lib
declare -a rm_lib_svc=(
    "sysinit.target.wants/dev-hugepages.mount"
    "sysinit.target.wants/sys-fs-fuse-connections.mount"
    "sysinit.target.wants/systemd-ask-password-console.path"
    "sysinit.target.wants/systemd-machine-id-commit.service"
    "sysinit.target.wants/systemd-sysctl.service"
    "sysinit.target.wants/systemd-update-done.service"
    "multi-user.target.wants/systemd-ask-password-wall.path"
    "timers.target.wants/systemd-tmpfiles-clean.timer")

for f in "${rm_lib_svc[@]}"; do
    rm -f ${TARGET_DIR}/usr/lib/systemd/system/$f
done

# Disable some default systemd services from /etc
declare -a rm_etc_svc=(
    "ctrl-alt-del.target"
    "sys-fs-fuse-connections.mount"
    "getty@.service"
    "remote-fs.target"
    "dropbear.service"
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
    "sysinit.target.wants/systemd-timesyncd.service"
    "default.target.wants/e2scrub_reap.service"
    "timers.target.wants/e2scrub_all.timer"
    "network-online.target.wants/systemd-networkd-wait-online.service")

for f in "${rm_etc_svc[@]}"; do
    rm -f ${TARGET_DIR}/etc/systemd/system/$f
done

# Make some services auto-stop when unneeded
declare -a autostop_svc=(
    "system/systemd-resolved.service"
    "system/systemd-networkd.service"
    "user/dropbear.service"
)

for f in "${autostop_svc[@]}"; do
    grep -qE '^StopWhenUnneeded' ${TARGET_DIR}/usr/lib/systemd/$f || \
    sed -zui "s/\n\[Service\]/StopWhenUnneeded=true\n\n\[Service\]/" \
        ${TARGET_DIR}/usr/lib/systemd/$f
done

# Delete some extra overhead
rm -rf ${TARGET_DIR}/usr/lib/python2.7/site-packages/zmq/tests
