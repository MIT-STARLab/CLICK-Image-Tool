# Defines how to install CLICK flight software
CLICK_FSW_VERSION = $(FSW_VERSION)
CLICK_FSW_SITE = $(call github,MIT-STARLab,CLICK-A-RPi,master)
CLICK_FSW_LICENSE = LGPL-3.0
CLICK_FSW_LICENSE_FILES = LICENSE.md

# Force kernel to export the needed symbols for the SPI driver at bus/driver
# The kernel is configured to strip unused symbols otherwise to save space
# The symbols.txt file can be generated using "make symbols" with the SPI driver Makefie, when built outside of buildroot
KVERSION = $(LINUX_VERSION_PROBED)
KSYMS = "$(BR2_EXTERNAL_CLICK_PATH)/package/click-fsw/symbols.txt"
CLICK_FSW_LINUX_CONFIG_FIXUPS = $(call KCONFIG_SET_OPT,CONFIG_UNUSED_KSYMS_WHITELIST,$(KSYMS))
CLICK_FSW_MODULE_SUBDIRS = bus/driver

# Compile the SPI driver
$(eval $(kernel-module))

# Install the flight software
define CLICK_FSW_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/local/fsw/bin
    rsync -a --exclude='.*' --exclude='*.md' --exclude='*~' --exclude='*.o' \
        $(@D)/ $(TARGET_DIR)/usr/local/fsw/
endef

# Move the kernel driver to /usr/local/fsw/bin
define CLICK_FSW_COPY_DRIVER
    mv $(TARGET_DIR)/lib/modules/$(KVERSION)/extra/click_spi.ko \
        $(TARGET_DIR)/usr/local/fsw/bin
endef

CLICK_FSW_POST_INSTALL_TARGET_HOOKS += CLICK_FSW_COPY_DRIVER

$(eval $(generic-package))
