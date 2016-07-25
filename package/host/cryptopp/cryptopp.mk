################################################################################
#
# cryptopp
#
################################################################################

CRYPTOPP_VERSION = 5.6.3
CRYPTOPP_SOURCE = cryptopp$(subst .,,$(CRYPTOPP_VERSION)).zip
CRYPTOPP_SITE = http://cryptopp.com/
CRYPTOPP_LICENSE = Boost-v1.0
CRYPTOPP_LICENSE_FILES = License.txt
CRYPTOPP_INSTALL_STAGING = YES

HOST_CRRYPTOPP_MAKE_OPTS = \
	$(HOST_CONFIGURE_OPTS) \
	LDFLAGS="$(HOST_LDFLAGS)"

define HOST_CRYPTOPP_BUILD_CMDS
	$(MAKE) -C $(@D) $(HOST_CRYPTOPP_MAKE_OPTS) -f GNUmakefile
	$(MAKE) -C $(@D) $(HOST_CRYPTOPP_MAKE_OPTS) libcryptopp.so
endef

define HOST_CRYPTOPP_INSTALL_CMDS
	$(INSTALL) -d ${HOST_DIR}/usr/include/cryptopp
	$(INSTALL) -D -m 644 $(@D)/*.h ${HOST_DIR}/usr/include/cryptopp/
	$(INSTALL) -D -m 0755 $(@D)/libcryptopp.so ${HOST_DIR}/usr/lib/libcryptopp.so
endef

define HOST_CRYPTOPP_EXTRACT_CMDS
	$(UNZIP) $(DL_DIR)/$(CRYPTOPP_SOURCE) -d $(@D)
endef

$(eval $(host-generic-package))
