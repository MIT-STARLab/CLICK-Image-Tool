# Defines how to install CLICK flight software
CLICK_FSW_VERSION = 69dedc82a2dbff2298b2f38559d5d77050ebb666
CLICK_FSW_SITE = $(call github,MIT-STARLab,CLICK-A-RPi,master)
CLICK_FSW_LICENSE = LGPL-3.0
CLICK_FSW_LICENSE_FILES = LICENSE.md
CLICK_FSW_MODULE_SUBDIRS = bus/driver

# Force kernel to export the needed symbols for the SPI driver
# The kernel is configured to strip unused symbols otherwise to save space
KSYMS = "$(BR2_EXTERNAL_CLICK_PATH)/package/click-fsw/symbols.txt"
CLICK_FSW_LINUX_CONFIG_FIXUPS = $(call KCONFIG_SET_OPT,CONFIG_UNUSED_KSYMS_WHITELIST,$(KSYMS))

$(eval $(kernel-module))

# Install the flight software to /usr/local/fsw
define CLICK_FSW_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/local/fsw/bin
    mkdir -p $(TARGET_DIR)/usr/local/fsw/.ssh
    mkdir -p $(TARGET_DIR)/usr/local/fsw/.config/systemd/user/default.target.wants
    ln -sfn .config/systemd/user $(TARGET_DIR)/usr/local/fsw/services
    rsync -a --exclude='.*' --exclude='*.md' --exclude='*~' --exclude='*.o' \
        $(@D)/ $(TARGET_DIR)/usr/local/fsw/
endef

# Move the built kernel driver to /usr/local/fsw/bin and create a symlink to it
define CLICK_FSW_SYMLINK_DRIVER
    mv $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/click_spi.ko \
        $(TARGET_DIR)/usr/local/fsw/bin
    ln -sfn /usr/local/fsw/bin/click_spi.ko \
        $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/click_spi.ko
endef
CLICK_FSW_POST_TARGET_INSTALL_HOOKS += CLICK_FSW_SYMLINK_DRIVER

$(eval $(generic-package))
