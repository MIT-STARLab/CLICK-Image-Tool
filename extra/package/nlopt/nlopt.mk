# Defines how to install NLopt from Steven Johnson
NLOPT_VERSION = v2.7.0
NLOPT_SITE = $(call github,stevengj,nlopt,$(NLOPT_VERSION))
NLOPT_LICENSE = MIT
NLOPT_LICENSE_FILES = COPYING
NLOPT_INSTALL_STAGING = YES

$(eval $(cmake-package))
