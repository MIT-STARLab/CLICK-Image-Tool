# Defines how to install custom CLICK FPGA image
# FPGA_VERSION is defined in build.sh
CLICK_FPGA_VERSION = $(FPGA_VERSION)
CLICK_FPGA_SITE = $(call github,MIT-STARLab,CLICK-A-FPGA,$(FPGA_VERSION))
CLICK_FPGA_LICENSE = LGPL-3.0
CLICK_FPGA_LICENSE_FILES = LICENSE.md

# Install the FPGA image
define CLICK_FPGA_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/usr/local/fsw/bin
	$(INSTALL) -m 0644 $(@D)/test3.xsvf $(TARGET_DIR)/usr/local/fsw/bin/fpga_old.xsvf
	$(INSTALL) -m 0644 $(@D)/protected_output_3.xsvf $(TARGET_DIR)/usr/local/fsw/bin/fpga_prot.xsvf
	$(INSTALL) -m 0644 $(@D)/protected_output_3_stall_inverted.xsvf $(TARGET_DIR)/usr/local/fsw/bin/fpga_prot_inv.xsvf
	$(INSTALL) -m 0644 $(@D)/protected_output_3.xsvf $(TARGET_DIR)/usr/local/fsw/bin/fpga.xsvf
endef

$(eval $(generic-package))
