################################################################################
#
# l4t/nvidia-drivers
#
################################################################################

NVIDIA_CFVC_VERSION_MAJOR = 21
NVIDIA_CFVC_VERSION_MINOR = 3-parrot.20150606
NVIDIA_CFVC_VERSION = $(NVIDIA_CFVC_VERSION_MAJOR).$(NVIDIA_CFVC_VERSION_MINOR)
#NVIDIA_CFVC_SOURCE = parrot_update.tbz2
NVIDIA_CFVC_SITE_METHOD = local
NVIDIA_CFVC_SITE = /home/nikolaus.schulz/git/ad/nvidia-cfvc
NVIDIA_CFVC_LICENSE = custom
NVIDIA_CFVC_DEPENDENCIES = nvidia-drivers
NVIDIA_CFVC_INSTALL_STAGING = YES
NVIDIA_CFVC_INSTALL_TARGET = YES

define NVIDIA_CFVC_BUILD_CMDS
	$(MAKE) -C $(@D) CROSS_COMPILE=$(TARGET_CROSS) tinycamera
endef

define NVIDIA_CFVC_INSTALL_LIB_CMDS
	$(INSTALL) -d $(1)/usr/lib/tegra/
	$(INSTALL) -d $(1)/usr/lib/tegra-egl/
	$(INSTALL) -m 0644 $(@D)/libs/tegra/*.so* \
		$(1)/usr/lib/tegra/
	$(INSTALL) -m 0644 $(@D)/libs/tegra-egl/*.so* \
		$(1)/usr/lib/tegra-egl/
endef

NVIDIA_CFVC_INSTALL_STAGING_CMDS = $(call $(NVIDIA_CFVC_INSTALL_LIB_CMDS), $(STAGING_DIR))

define NVIDIA_CFVC_INSTALL_TARGET_CMDS
	$(call $(NVIDIA_CFVC_INSTALL_LIB_CMDS), $(TARGET_DIR))
	$(INSTALL) -d $(TARGET_DIR)/usr/bin
	$(INSTALL) $(@D)/bin/tinycamera $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
