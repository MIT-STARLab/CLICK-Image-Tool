# Defines FPGALink libraries makefile
FPGALINK_VERSION = ad40601234f5be9ae2b0640dde3fb77d31a0323f
FPGALINK_SITE_METHOD = git
FPGALINK_SITE = https://github.com/makestuff/fpgalink.git
FPGALINK_GIT_SUBMODULES = YES
FPGALINK_LICENSE = LGPL-3.0
FPGALINK_LICENSE_FILES = COPYING
FPGALINK_DEPENDENCIES = libusb

# Fix wrong default install folder
define FPGALINK_MOVE_LIBS
	mv ${TARGET_DIR}/usr/bin/libargtable2.so ${TARGET_DIR}/usr/lib/
	mv ${TARGET_DIR}/usr/bin/liberror.so ${TARGET_DIR}/usr/lib/
	mv ${TARGET_DIR}/usr/bin/libusbwrap.so ${TARGET_DIR}/usr/lib/
	mv ${TARGET_DIR}/usr/bin/libbuffer.so ${TARGET_DIR}/usr/lib/
	mv ${TARGET_DIR}/usr/bin/libfx2loader.so ${TARGET_DIR}/usr/lib/
	mv ${TARGET_DIR}/usr/bin/libfpgalink.so ${TARGET_DIR}/usr/lib/
endef

FPGALINK_POST_INSTALL_TARGET_HOOKS += FPGALINK_MOVE_LIBS

$(eval $(cmake-package))

