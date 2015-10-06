################################################################################
#
# nodm
#
################################################################################

NODM_VERSION = 0.7
NODM_SITE = http://www.enricozini.org/sw/nodm
NODM_LICENSE = GPLv2
NODM_LICENSE_FILES = COPYING
NODM_DEPENDENCIES = linux-pam
NODM_INSTALL_STAGING = NO

define NODM_INSTALL_EXTRA
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL)/package/extra/nodm/S90nodm \
		$(TARGET_DIR)/etc/init.d/S90nodm
	$(INSTALL) -D -m 0644 $(BR2_EXTERNAL)/package/extra/nodm/pam.nodm \
		$(TARGET_DIR)/etc/pam.d/nodm
endef

NODM_POST_INSTALL_TARGET_HOOKS += NODM_INSTALL_EXTRA

$(eval $(autotools-package))
