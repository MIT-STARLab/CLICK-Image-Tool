################################################################################
#
# python-crccheck
#
################################################################################

PYTHON_CRCCHECK_VERSION = 1.0
PYTHON_CRCCHECK_SOURCE = crccheck-$(PYTHON_CRCCHECK_VERSION).tar.gz
PYTHON_CRCCHECK_SITE = https://files.pythonhosted.org/packages/b0/40/21652b902a244a8516dc314e6e0053179164ca703628b53419a3b4ec063f
PYTHON_CRCCHECK_SETUP_TYPE = setuptools
PYTHON_CRCCHECK_LICENSE = GNU General Public License v3 or later (GPLv3+)

$(eval $(python-package))
