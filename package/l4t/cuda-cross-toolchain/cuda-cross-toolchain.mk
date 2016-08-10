HOST_CUDA_CROSS_TOOLCHAIN_VERSION = 6.5
HOST_CUDA_CROSS_TOOLCHAIN_SITE = http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/
HOST_CUDA_CROSS_TOOLCHAIN_SOURCE = cuda-core-6-5_6.5-19_amd64.deb
HOST_CUDA_CROSS_TOOLCHAIN_EXTRA_DOWNLOADS = $(cuda-cross-toolchain-license-deb)
HOST_CUDA_CROSS_TOOLCHAIN_LICENSE = EULA
HOST_CUDA_CROSS_TOOLCHAIN_LICENSE_FILES = $(HOST_DIR)/usr/local/cuda-6.5/doc/EULA.txt
HOST_CUDA_CROSS_TOOLCHAIN_REDISTRIBUTE = NO

HOST_CUDA_CROSS_TOOLCHAIN_DEPENDENCIES = cuda

cuda-cross-toolchain-license-deb := cuda-license-6-5_6.5-19_amd64.deb

define cuda-cross-toolchain-unpack-debfile-to
	ar p $(1) data.tar.gz | $(TAR) -C '$(2)' -z $(TAR_OPTIONS) -
endef

define HOST_CUDA_CROSS_TOOLCHAIN_EXTRACT_CMDS
	$(call cuda-cross-toolchain-unpack-debfile-to,$(DL_DIR)/$(HOST_CUDA_CROSS_TOOLCHAIN_SOURCE),$(HOST_CUDA_CROSS_TOOLCHAIN_DIR))
	$(call cuda-cross-toolchain-unpack-debfile-to,$(DL_DIR)/$(cuda-cross-toolchain-license-deb),$(HOST_CUDA_CROSS_TOOLCHAIN_DIR))
endef

define cuda-cross-toolchain-install-from-to
	cd '$(1)' && find . \
		-path ./usr/share/lintian -prune -o -print0 | \
		cpio -p0dum '$(2)'
endef

define HOST_CUDA_CROSS_TOOLCHAIN_INSTALL_CMDS
	$(call cuda-cross-toolchain-install-from-to,$(HOST_CUDA_CROSS_TOOLCHAIN_DIR),$(HOST_DIR))
	ln -Tsf cuda-$(HOST_CUDA_CROSS_TOOLCHAIN_VERSION) '$(HOST_DIR)/usr/local/cuda'
endef

$(eval $(host-generic-package))
