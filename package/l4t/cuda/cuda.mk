CUDA_VERSION = 6.5
CUDA_SITE = http://developer.download.nvidia.com/embedded/L4T/r21_Release_v3.0/
CUDA_SOURCE = cuda-repo-l4t-r21.3-6-5-prod_6.5-42_armhf.deb
CUDA_LICENSE = EULA
CUDA_LICENSE_FILES = $(notdir $(tempdir-repo-root))/usr/share/doc/cuda-repo-l4t-r21.3-6-5-prod/copyright
CUDA_REDISTRIBUTE = NO

CUDA_INSTALL_TARGET = YES
CUDA_INSTALL_STAGING = YES

package-basenames := cuda-cublas cuda-cudart cuda-cufft cuda-curand \
	cuda-cusparse cuda-npp

dash-version := $(subst .,-,$(CUDA_VERSION))
target-package-names := $(addsuffix -$(dash-version),$(package-basenames))
staging-package-names := $(addsuffix -dev-$(dash-version),$(package-basenames))

tempdir-repo-root = $(CUDA_DIR)/repo
tempdir-repo      = $(tempdir-repo-root)/var/cuda-repo-$(dash-version)-prod

tempdir-target  = $(CUDA_DIR)/for-target
tempdir-staging = $(CUDA_DIR)/for-staging

define unpack-debfile-to
	ar p $(1) data.tar.gz | $(TAR) -C '$(2)' -z $(TAR_OPTIONS) -
endef

define unpack-debian-packages-by-name-to
	mkdir -p '$(2)'
	set -e; cd '$(tempdir-repo)' && \
	for packname in $(1); do \
		$(call unpack-debfile-to,$${packname}*.deb,$(2)); \
	done
endef

define CUDA_EXTRACT_CMDS
	mkdir -p '$(tempdir-repo-root)'
	$(call unpack-debfile-to,$(DL_DIR)/$(CUDA_SOURCE),$(tempdir-repo-root))
	$(call unpack-debian-packages-by-name-to,$(target-package-names),$(tempdir-target))
	$(call unpack-debian-packages-by-name-to,$(staging-package-names),$(tempdir-staging))
endef

define install-from-to
	cd '$(1)' && find . \
		-path ./usr/share/lintian -prune -o -print0 | \
		cpio -p0dum '$(2)'
endef

define CUDA_INSTALL_TARGET_CMDS
	$(call install-from-to,$(tempdir-target),$(TARGET_DIR))
	ln -Tsf cuda-$(CUDA_VERSION) '$(TARGET_DIR)/usr/local/cuda'
endef

define CUDA_INSTALL_STAGING_CMDS
	$(call install-from-to,$(tempdir-target),$(STAGING_DIR))
	$(call install-from-to,$(tempdir-staging),$(STAGING_DIR))
	ln -Tsf cuda-$(CUDA_VERSION) '$(STAGING_DIR)/usr/local/cuda'
endef

$(eval $(generic-package))
