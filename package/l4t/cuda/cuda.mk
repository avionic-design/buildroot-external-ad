# URLs extracted from JetPack v2.2.1
CUDA_L4T_VERSION = 21.5
CUDA_VERSION_PATCHLVL = 53
CUDA_VERSION = 6.5
CUDA_SITE = http://developer.download.nvidia.com/devzone/devcenter/mobile/jetpack_l4t/005/linux-x64
CUDA_SOURCE = cuda-repo-l4t-r$(CUDA_L4T_VERSION)-$(cuda-dash-version)-local_$(CUDA_VERSION)-$(CUDA_VERSION_PATCHLVL)_armhf.deb
CUDA_LICENSE = EULA
CUDA_LICENSE_FILES = $(notdir $(cuda-tempdir-staging))/usr/local/cuda-$(CUDA_VERSION)/doc/EULA.txt
CUDA_REDISTRIBUTE = NO

CUDA_INSTALL_TARGET = YES
CUDA_INSTALL_STAGING = YES

cuda-package-basenames := cuda-cublas cuda-cudart cuda-cufft cuda-curand \
	cuda-cusparse cuda-npp cuda-cusolver
cuda-target-package-basenames = cuda-command-line-tools
cuda-staging-package-basenames = \
	cuda-misc-headers cuda-driver-dev cuda-license

cuda-dash-version := $(subst .,-,$(CUDA_VERSION))
cuda-target-package-names := $(addsuffix -$(cuda-dash-version), \
	$(cuda-package-basenames) \
	$(cuda-target-package-basenames))
cuda-staging-package-names := $(addsuffix -dev-$(cuda-dash-version), \
	$(cuda-package-basenames)) \
	cuda-cudart

cuda-tempdir-repo-root = $(CUDA_DIR)/repo
cuda-tempdir-repo      = $(cuda-tempdir-repo-root)/var/cuda-repo-$(cuda-dash-version)-local

cuda-tempdir-target  = $(CUDA_DIR)/for-target
cuda-tempdir-staging = $(CUDA_DIR)/for-staging

define cuda-unpack-debfile-to
	ar p $(1) data.tar.gz | $(TAR) -C '$(2)' -z $(TAR_OPTIONS) -
endef

define cuda-unpack-debian-packages-by-name-to
	mkdir -p '$(2)'
	set -e; cd '$(cuda-tempdir-repo)' && \
	for packname in $(1); do \
		$(call cuda-unpack-debfile-to,$${packname}*.deb,$(2)); \
	done
endef

define CUDA_EXTRACT_CMDS
	mkdir -p '$(cuda-tempdir-repo-root)'
	$(call cuda-unpack-debfile-to,$(DL_DIR)/$(CUDA_SOURCE),$(cuda-tempdir-repo-root))
	$(call cuda-unpack-debian-packages-by-name-to,$(cuda-target-package-names),$(cuda-tempdir-target))
	$(call cuda-unpack-debian-packages-by-name-to,$(cuda-staging-package-names),$(cuda-tempdir-staging))
endef

define cuda-install-from-to
	cd '$(1)' && find . \
		-path ./usr/share/lintian -prune -o -print0 | \
		cpio -p0dum '$(2)'
endef

define CUDA_INSTALL_TARGET_CMDS
	$(call cuda-install-from-to,$(cuda-tempdir-target),$(TARGET_DIR))
	ln -Tsf cuda-$(CUDA_VERSION) '$(TARGET_DIR)/usr/local/cuda'
	$(INSTALL) -d '$(TARGET_DIR)/etc/profile.d'
	$(INSTALL) -m 644 '$(CUDA_PKGDIR)/cuda-ld-library-path.sh' \
		'$(TARGET_DIR)/etc/profile.d'
endef

define CUDA_INSTALL_STAGING_CMDS
	$(call cuda-install-from-to,$(cuda-tempdir-staging),$(STAGING_DIR))
	ln -Tsf cuda-$(CUDA_VERSION) '$(STAGING_DIR)/usr/local/cuda'
endef

$(eval $(generic-package))
