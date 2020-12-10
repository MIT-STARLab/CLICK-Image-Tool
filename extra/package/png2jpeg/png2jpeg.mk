PNG2JPEG_VERSION = r73
PNG2JPEG_SITE = svn://svn.code.sf.net/p/png2jpeg/code
PNG2JPEG_LICENSE = GPL-2.0
PNG2JPEG_LICENSE_FILES = license.txt
LIBFOO_DEPENDENCIES = zlib libpng libjpeg 

define PNG2JPEG_BUILD_CMDS
	$(MAKE) CC=$(TARGET_CC) OPTIMS=-Os INCDIRS=-I$(STAGING_DIR)/usr/include LIBDIRS=-L$(STAGING_DIR)/usr/lib -C $(@D) all
endef

define PNG2JPEG_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/png2jpeg $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
