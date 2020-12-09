# Defines CLICK flight software package via a git tag
CLICK_FSW_VERSION = 69dedc82a2dbff2298b2f38559d5d77050ebb666
CLICK_FSW_SITE = $(call github,MIT-STARLab,CLICK-A-RPi,master)
CLICK_FSW_LICENSE = LGPL-3.0
CLICK_FSW_LICENSE_FILES = LICENSE.md
CLICK_FSW_MODULE_SUBDIRS = bus/driver
CLICK_FSW_LINUX_CONFIG_FIXUPS = $(call KCONFIG_SET_OPT,CONFIG_UNUSED_KSYMS_WHITELIST,"$(BR2_EXTERNAL_CLICK_PATH)/package/click-fsw/ksym.txt")

$(eval $(kernel-module))
$(eval $(generic-package))

# Command to install the flight software to /root
define CLICK_FSW_INSTALL_TARGET_CMDS
	rsync -a --exclude='.*' --exclude='*.md' --exclude='*~' --exclude='*.o'} $(@D)/ $(TARGET_DIR)/root/
endef
