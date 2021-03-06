#!/bin/bash
# Post-buildroot OS packaging script, inspired by:
# buildroot/board/raspberrypi3/post-image.sh
# This takes the packaged OS and creates an eMMC image with all partitions
set -u
set -e

# Prepare kernel and bootloader config files
[ -f "${BINARIES_DIR}/zImage" ] && mv "${BINARIES_DIR}/zImage" "${BINARIES_DIR}/kernel.img"
echo "root=/dev/mmcblk0p2 rootfstype=squashfs console=none dwc_otg.lpm_enable=0 rootwait noinitrd" > \
    "${BINARIES_DIR}/cmdline.txt"
cp "../config_rpi.txt" "${BINARIES_DIR}/config.txt"

# Constants to help calculate partition sizes
RPI_FLASH_SECTOR_SIZE=512
RPI_FLASH_TOTAL_SECTORS=7634943
BOOT_PART_OVERHEAD=$((86*RPI_FLASH_SECTOR_SIZE))
EXT4_HEADER_SIZE=5120

# The actual large R/W ext4 filesystem is created by the OS on first boot
# (see overlay/usr/lib/systemd/system/fs-initialize.service)
# Here, we only write a small empty block to make sure the ext4 header is empty after reflashing 
# Otherwise the ext4 auto-mount might freak out if the header is uninitialized on first boot
dd if=/dev/zero of=${BINARIES_DIR}/rw_zeros.ext4 seek=$EXT4_HEADER_SIZE count=0 bs=1 2>/dev/null

# Function to align a value to flash sector size
function align_to_flash {
    SIZE_ALIGNED=$(($1+RPI_FLASH_SECTOR_SIZE-1-(($1+RPI_FLASH_SECTOR_SIZE-1)%RPI_FLASH_SECTOR_SIZE))) 
}

# Files used to calculate boot partition size
declare -a bootfiles=(
    "overlays/click_spi.dtbo"
    "overlays/spi1-1cs.dtbo"
    "bcm2710-rpi-cm3.dtb"
    "cmdline.txt"
    "config.txt"
    "kernel.img"
    "rpi-firmware/bootcode.bin"
    "rpi-firmware/fixup.dat"
    "rpi-firmware/start.elf")

# Calculate boot partition size
for f in "${bootfiles[@]}"; do
    align_to_flash $(stat --printf="%s" "${BINARIES_DIR}/$f")
    BOOT_PART_OVERHEAD=$((BOOT_PART_OVERHEAD+SIZE_ALIGNED))
done

# Get OS partition size
align_to_flash $(stat --printf="%s" "${BINARIES_DIR}/rootfs.squashfs")
OS_PART_SIZE=$SIZE_ALIGNED

# Calculate available space for the R/W ext4 partition
RW_PART_SIZE=$(((RPI_FLASH_TOTAL_SECTORS*RPI_FLASH_SECTOR_SIZE)-BOOT_PART_OVERHEAD-OS_PART_SIZE))

# Files & folders to put into boot FAT image
declare -a fatfiles=(
    "overlays"
    "bcm2710-rpi-cm3.dtb"
    "cmdline.txt"
    "config.txt"
    "kernel.img"
    "rpi-firmware/bootcode.bin"
    "rpi-firmware/fixup.dat"
    "rpi-firmware/start.elf")

# Prepare config for the buildroot genimage tool (https://github.com/pengutronix/genimage)
fatfiles=$(printf "\"%s\"," "${fatfiles[@]}")
fatfiles=${fatfiles%?}
cat > "${BUILD_DIR}/genimage.cfg" <<EOF
image boot.vfat { vfat { extraargs = "-F 16 -s 1" files = { $fatfiles } } size = $BOOT_PART_OVERHEAD }
image click_emmc.img {
    hdimage {}
    partition boot { partition-type = 0xE bootable = "true" image = "boot.vfat" }
    partition os { partition-type = 0x83 image = "rootfs.squashfs" }
    partition rw { partition-type = 0x83 size = $RW_PART_SIZE image = "rw_zeros.ext4" }
}
EOF

# The below is copied from buildroot/board/raspberrypi3/post-image.sh
# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.
trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
rm -rf "${GENIMAGE_TMP}"

genimage \
    --rootpath "${ROOTPATH_TMP}"   \
    --tmppath "${GENIMAGE_TMP}"    \
    --inputpath "${BINARIES_DIR}"  \
    --outputpath "${BINARIES_DIR}" \
    --config "${BUILD_DIR}/genimage.cfg"

# Create a golden image by prepending the USB bootloader (msd.elf) and the image size
if [ -f "${BINARIES_DIR}/click_emmc.img" ]; then
    # Get image size in sectors as a little-endian hex integer
    IMG_SIZE=$(stat --printf="%s" "${BINARIES_DIR}/click_emmc.img")
    IMG_SIZE=$((IMG_SIZE/RPI_FLASH_SECTOR_SIZE))
    IMG_SIZE=$(printf "%.8x" $IMG_SIZE)
    IMG_SIZE=${IMG_SIZE:6:2}${IMG_SIZE:4:2}${IMG_SIZE:2:2}${IMG_SIZE:0:2}
    cp "${BINARIES_DIR}/click_emmc.img" "${BASE_DIR}/../img/"
    cp "${HOST_DIR}/usr/share/rpiboot/msd.elf" "${BASE_DIR}/../img/click_golden.img"
    chmod -x "${BASE_DIR}/../img/click_golden.img"
    echo -n $IMG_SIZE | xxd -r -p >> "${BASE_DIR}/../img/click_golden.img"
    cat "${BINARIES_DIR}/click_emmc.img" >> "${BASE_DIR}/../img/click_golden.img"
fi

exit $?
