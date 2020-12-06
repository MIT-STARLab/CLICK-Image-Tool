# Defines CLICK flight software package via a git tag
CLICK_VERSION = v0.1
CLICK_SITE = $(call github,MIT-STARLab,CLICK-A-RPi,master)
CLICK_LICENSE = LGPL-3.0
CLICK_LICENSE_FILES = LICENSE.md
CLICK_MODULE_SUBDIRS = bus/driver

# The kernel driver needs kfifo symbols, which no other modules use...
# To include the symbols, force the kernel to build a kfifo sample module
CLICK_LINUX_CONFIG_FIXUPS = $(call KCONFIG_ENABLE_OPT,CONFIG_SAMPLES) $(call KCONFIG_SET_OPT,CONFIG_SAMPLE_KFIFO,m)

# Command to install the flight software to /root
define CLICK_INSTALL_TARGET_CMDS
	rsync -a --exclude='.*' --exclude='*.md' --exclude='*~' --exclude='*.o'} $(@D)/ $(TARGET_DIR)/root/
endef

$(eval $(kernel-module))
$(eval $(generic-package))
