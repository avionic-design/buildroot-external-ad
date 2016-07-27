################################################################################
#
# tegrarcm
#
################################################################################

TEGRARCM_VERSION = ec1eeac
TEGRARCM_SITE = $(call github,NVIDIA,tegrarcm,$(TEGRARCM_VERSION))
TEGRARCM_LICENSE = BSD-3c / NVIDIA Software License (src/miniloader)
TEGRARCM_LICENSE_FILE = LICENSE
TEGRARCM_AUTORECONF = YES
HOST_TEGRARCM_DEPENDENCIES = host-libusb host-pkgconf host-cryptopp
HOST_TEGRARCM_MAKE_OPTS = SYSROOT=$(HOST_DIR)

$(eval $(host-autotools-package))
