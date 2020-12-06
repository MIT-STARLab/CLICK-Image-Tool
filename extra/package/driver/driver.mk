CLICK_DRIVER_VERSION = 1.0
CLICK_DRIVER_SITE = $(BR2_EXTERNAL_CLICK_PATH)/../click/bus/driver
CLICK_DRIVER_SITE_METHOD = local
$(eval $(kernel-module))
$(eval $(generic-package))