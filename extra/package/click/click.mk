CLICK_VERSION = 1.0
CLICK_SITE = $(call github,MIT-STARLab,CLICK-A-RPi,master)
CLICK_LICENSE = LGPL-3.0
CLICK_LICENSE_FILES = LICENSE.md
CLICK_LINUX_CONFIG_FIXUPS = $(call KCONFIG_ENABLE_OPT,CONFIG_SAMPLE_KFIFO)
CLICK_MODULE_SUBDIRS = bus/driver

$(eval $(kernel-module))
$(eval $(generic-package))
