# Defines how to download and install the needed Matrix Vision libraries
MV_MAJOR = 2
MV_MINOR = 40.3
MATRIX_VISION_VERSION = $(MV_MAJOR).$(MV_MINOR)
MATRIX_VISION_SOURCE = mvBlueFOX-ARMhf_gnueabi-$(MATRIX_VISION_VERSION).tgz
MATRIX_VISION_SITE = http://static.matrix-vision.com/mvIMPACT_Acquire/$(MATRIX_VISION_VERSION)
MATRIX_VISION_INSTALL_STAGING = YES
MATRIX_VISION_DEPENDENCIES = expat

define MATRIX_VISION_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/include/DriverBase/Include
	$(INSTALL) -d $(STAGING_DIR)/usr/include/mvDeviceManager/Include
	$(INSTALL) -d $(STAGING_DIR)/usr/include/mvPropHandling/Include
	$(INSTALL) -d $(STAGING_DIR)/usr/include/mvIMPACT_CPP
	$(INSTALL) -d $(STAGING_DIR)/usr/include/common/crt
	$(INSTALL) -D -m 0644 $(@D)/DriverBase/Include/*.h $(STAGING_DIR)/usr/include/DriverBase/Include
	$(INSTALL) -D -m 0644 $(@D)/mvDeviceManager/Include/*.h $(STAGING_DIR)/usr/include/mvDeviceManager/Include
	$(INSTALL) -D -m 0644 $(@D)/mvPropHandling/Include/*.h $(STAGING_DIR)/usr/include/mvPropHandling/Include
	$(INSTALL) -D -m 0644 $(@D)/mvIMPACT_CPP/*.h $(STAGING_DIR)/usr/include/mvIMPACT_CPP
	$(INSTALL) -D -m 0644 $(@D)/common/auto_array_ptr.h $(STAGING_DIR)/usr/include/common
	$(INSTALL) -D -m 0644 $(@D)/common/crt/mvstring.h $(STAGING_DIR)/usr/include/common/crt
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvPropHandling.so.$(MATRIX_VISION_VERSION) $(STAGING_DIR)/usr/lib
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvDeviceManager.so.$(MATRIX_VISION_VERSION) $(STAGING_DIR)/usr/lib
	ln -sfn libmvPropHandling.so.$(MATRIX_VISION_VERSION) $(STAGING_DIR)/usr/lib/libmvPropHandling.so.$(MV_MAJOR)
	ln -sfn libmvPropHandling.so.$(MV_MAJOR) $(STAGING_DIR)/usr/lib/libmvPropHandling.so
	ln -sfn libmvDeviceManager.so.$(MATRIX_VISION_VERSION) $(STAGING_DIR)/usr/lib/libmvDeviceManager.so.$(MV_MAJOR)
	ln -sfn libmvDeviceManager.so.$(MV_MAJOR) $(STAGING_DIR)/usr/lib/libmvDeviceManager.so
endef

define MATRIX_VISION_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvPropHandling.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvDeviceManager.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib
	ln -sfn libmvPropHandling.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib/libmvPropHandling.so.$(MV_MAJOR)
	ln -sfn libmvPropHandling.so.$(MV_MAJOR) $(TARGET_DIR)/usr/lib/libmvPropHandling.so
	ln -sfn libmvDeviceManager.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib/libmvDeviceManager.so.$(MV_MAJOR)
	ln -sfn libmvDeviceManager.so.$(MV_MAJOR) $(TARGET_DIR)/usr/lib/libmvDeviceManager.so
endef

$(eval $(generic-package))
