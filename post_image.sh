#!/bin/bash
# Post buildroot image generation script, based on:
# buildroot/board/raspberrypi3/post-image.sh
set -e

# Copy kernel and boot config files
[ -f "${BINARIES_DIR}/zImage" ] && mv "${BINARIES_DIR}/zImage" "${BINARIES_DIR}/kernel.img"
cp "../config_rpi.txt" "${BINARIES_DIR}/config.txt"
cp "../rpi_cmdline.txt" "${BINARIES_DIR}/cmdline.txt"

# Compile SPI driver overlay
if [ ! -d "${BINARIES_DIR}/overlays" ] ; then
	mkdir "${BINARIES_DIR}/overlays"
	dtc -O dtb -o "${BINARIES_DIR}/overlays/click_spi.dtbo" -b 0 -@\
		"${TARGET_DIR}/root/bus/driver/click_spi.dts"
fi

# Calculate partition sizes
RPI_FLASH_SECTOR_SIZE=512
RPI_FLASH_TOTAL_SECTORS=7634943
RPI_BOOTPART_OVERHEAD=$((86*RPI_FLASH_SECTOR_SIZE))

function align_to_flash {
	SIZE_ALIGNED=$(($1+RPI_FLASH_SECTOR_SIZE-1-(($1+RPI_FLASH_SECTOR_SIZE-1)%RPI_FLASH_SECTOR_SIZE))) 
}

declare -a bootfiles=(
    "overlays/click_spi.dtbo"
    "bcm2710-rpi-cm3.dtb"
    "cmdline.txt"
    "config.txt"
    "kernel.img"
    "rpi-firmware/bootcode.bin"
    "rpi-firmware/fixup.dat"
    "rpi-firmware/start.elf")

for f in "${bootfiles[@]}"; do
    align_to_flash $(stat --printf="%s" "${BINARIES_DIR}/$f")
    RPI_BOOTPART_OVERHEAD=$((RPI_BOOTPART_OVERHEAD+SIZE_ALIGNED))
done

align_to_flash $(stat --printf="%s" "${BINARIES_DIR}/rootfs.squashfs")
RPI_ROOTPART_SIZE=$SIZE_ALIGNED

# Calculate free space for FSW partition
RPI_FSWPART_SIZE=$(((RPI_FLASH_TOTAL_SECTORS*RPI_FLASH_SECTOR_SIZE)-RPI_BOOTPART_OVERHEAD-RPI_ROOTPART_SIZE))

# Prepare config for genimage tool
bootfiles[0]="overlays"
bootfiles=$(printf "\"%s\"," "${bootfiles[@]}")
bootfiles=${bootfiles%?}
cat > "${BUILD_DIR}/genimage.cfg" <<EOF
image boot.vfat { vfat { extraargs = "-F 16 -s 1" files = { $bootfiles } } size = $RPI_BOOTPART_OVERHEAD } 
image sdcard.img {
	hdimage {}
	partition boot { partition-type = 0xE bootable = "true" image = "boot.vfat" }
	partition root { partition-type = 0x83 image = "rootfs.squashfs" }
	partition fsw { partition-type = 0x83 size = $RPI_FSWPART_SIZE }
}
EOF

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

exit $?
