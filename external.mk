# Helper for unpacking debian packages
INFLATE.deb = $(BR2_EXTERNAL)/inflate-debpkg.sh

include $(sort $(wildcard $(BR2_EXTERNAL)/package/*/*/*.mk))

# Make sure enlightenment is built with udisks support
ifeq ($(BR2_PACKAGE_UDISKS),y)
ENLIGHTENMENT_DEPENDENCIES += udisks
endif
#
# Ubuntu builds tiff with versioned symbols, thus Nvidia-provided
# binaries that link to libtiff want versioned symbols.
TIFF_CONF_OPTS += --enable-ld-version-script

include $(BR2_EXTERNAL)/install-versions.mk
