# Defines how to download and install the needed Matrix Vision libraries
MATRIX_VISION_VERSION = 2.40.3
MATRIX_VISION_SOURCE = mvBlueFOX-ARMhf_gnueabi-$(MATRIX_VISION_VERSION).tgz
MATRIX_VISION_SITE = http://static.matrix-vision.com/mvIMPACT_Acquire/$(MATRIX_VISION_VERSION)
MATRIX_VISION_INSTALL_STAGING = YES

# For staging, install headers and main libraries, so that PAT can compile successfully
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
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvPropHandling.so.$(MATRIX_VISION_VERSION) $(STAGING_DIR)/usr/lib/libmvPropHandling.so
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvDeviceManager.so.$(MATRIX_VISION_VERSION) $(STAGING_DIR)/usr/lib/libmvDeviceManager.so
endef

# For target, install all libraries and no headers
define MATRIX_VISION_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvPropHandling.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvDeviceManager.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvBlueFOX.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 0755 $(@D)/lib/armhf/libmvVirtualDevice.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 0755 $(wildcard $(@D)/Toolkits/expat/bin/armhf/lib/libexpat.so.1.*) $(TARGET_DIR)/usr/lib
	$(INSTALL) -m 0755 $(wildcard $(@D)/Toolkits/FreeImage3160/bin/Release/FreeImage/armhf/libfreeimage-3.*) $(TARGET_DIR)/usr/lib
	ln -sfn libmvPropHandling.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib/libmvPropHandling.so.2
	ln -sfn libmvPropHandling.so.2 $(TARGET_DIR)/usr/lib/libmvPropHandling.so
	ln -sfn libmvDeviceManager.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib/libmvDeviceManager.so.2
	ln -sfn libmvDeviceManager.so.2 $(TARGET_DIR)/usr/lib/libmvDeviceManager.so
	ln -sfn libmvBlueFOX.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib/libmvBlueFOX.so.2
	ln -sfn libmvBlueFOX.so.2 $(TARGET_DIR)/usr/lib/libmvBlueFOX.so
	ln -sfn libmvVirtualDevice.so.$(MATRIX_VISION_VERSION) $(TARGET_DIR)/usr/lib/libmvVirtualDevice.so.2
	ln -sfn libmvVirtualDevice.so.2 $(TARGET_DIR)/usr/lib/libmvVirtualDevice.so
	ln -sfn $(notdir $(wildcard $(@D)/Toolkits/expat/bin/armhf/lib/libexpat.so.1.*)) $(TARGET_DIR)/usr/lib/libexpat.so.1
	ln -sfn libexpat.so.1 $(TARGET_DIR)/usr/lib/libexpat.so
	ln -sfn $(notdir $(wildcard $(@D)/Toolkits/FreeImage3160/bin/Release/FreeImage/armhf/libfreeimage-3.*)) $(TARGET_DIR)/usr/lib/libfreeimage.so.3
	ln -sfn libfreeimage.so.3 $(TARGET_DIR)/usr/lib/libfreeimage.so
endef

$(eval $(generic-package))
