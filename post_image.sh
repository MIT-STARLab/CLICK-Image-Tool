#!/bin/bash
# Post buildroot image generation script, based on:
# buildroot/board/raspberrypi3/post-image.sh
set -e

[ -f "${BINARIES_DIR}/zImage" ] && mv "${BINARIES_DIR}/zImage" "${BINARIES_DIR}/kernel"
[ ! -f "${BINARIES_DIR}/config.txt" ] && cp "../config_rpi.txt" "${BINARIES_DIR}/config.txt"

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
	--config "../config_image.txt"

exit $?
