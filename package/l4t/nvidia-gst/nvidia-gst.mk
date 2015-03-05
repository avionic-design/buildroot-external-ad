################################################################################
#
# l4t/nvidia-gst
#
################################################################################

NVIDIA_GST_VERSION = 21.2.0
NVIDIA_GST_SOURCE = Tegra124_Linux_R$(NVIDIA_GST_VERSION)_armhf.tbz2
NVIDIA_GST_SITE = http://developer.download.nvidia.com/mobile/tegra/l4t/r$(NVIDIA_GST_VERSION)/pm375_release_armhf/
NVIDIA_GST_LICENSE = custom
NVIDIA_GST_LICENSE_FILES = LICENSE
NVIDIA_GST_INSTALL_STAGING = YES
NVIDIA_GST_INSTALL_TARGET = YES

nvidia-gst-stage2-tarball := nv_sample_apps/nvgstapps.tbz2
nvidia-gst-stage1-unpack-these := $(addprefix Linux_for_Tegra/nv_tegra/, \
	$(NVIDIA_GST_LICENSE_FILES) $(nvidia-gst-stage2-tarball))

define NVIDIA_GST_EXTRACT_CMDS
	$(call suitable-extractor,$(NVIDIA_GST_SOURCE)) $(DL_DIR)/$(NVIDIA_GST_SOURCE) | \
	$(TAR) -C $(NVIDIA_GST_DIR) $(TAR_STRIP_COMPONENTS)=2 $(TAR_OPTIONS) - $(nvidia-gst-stage1-unpack-these)
	$(call suitable-extractor,$(nvidia-gst-stage2-tarball)) $(NVIDIA_GST_DIR)/$(nvidia-gst-stage2-tarball) | \
	$(TAR) -C $(NVIDIA_GST_DIR) $(TAR_OPTIONS) -
	$(RM) -r $(NVIDIA_GST_DIR)/$(dir $(nvidia-gst-stage2-tarball))
endef

define NVIDIA_GST_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/lib/gstreamer-0.10/
	$(INSTALL) -d $(STAGING_DIR)/usr/lib/gstreamer-1.0/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/*.so.0 $(STAGING_DIR)/usr/lib/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/gstreamer-0.10/*.so $(STAGING_DIR)/usr/lib/gstreamer-0.10/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/gstreamer-1.0/*.so $(STAGING_DIR)/usr/lib/gstreamer-1.0/
endef

define NVIDIA_GST_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/usr/lib/gstreamer-0.10/
	$(INSTALL) -d $(TARGET_DIR)/usr/lib/gstreamer-1.0/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/*.so.0 $(TARGET_DIR)/usr/lib/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/gstreamer-0.10/*.so $(TARGET_DIR)/usr/lib/gstreamer-0.10/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/gstreamer-1.0/*.so $(TARGET_DIR)/usr/lib/gstreamer-1.0/

	$(INSTALL) -D -m 0755 $(@D)/usr/bin/nvgst* $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
