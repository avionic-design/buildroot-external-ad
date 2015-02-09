################################################################################
#
# l4t/nvidia-drivers
#
################################################################################

NVIDIA_DRIVERS_VERSION = 21.2.0
NVIDIA_DRIVERS_SOURCE = Tegra124_Linux_R$(NVIDIA_DRIVERS_VERSION)_armhf.tbz2
NVIDIA_DRIVERS_SITE = http://developer.download.nvidia.com/mobile/tegra/l4t/r$(NVIDIA_DRIVERS_VERSION)/pm375_release_armhf/
NVIDIA_DRIVERS_LICENSE = custom
NVIDIA_DRIVERS_LICENSE_FILES = Linux_for_Tegra/nv_tegra/LICENSE
NVIDIA_DRIVERS_INSTALL_STAGING = YES
NVIDIA_DRIVERS_INSTALL_TARGET = YES

define NVIDIA_DRIVERS_EXTRACT_CMDS
	$(call suitable-extractor,$(NVIDIA_DRIVERS_SOURCE)) $(DL_DIR)/$(NVIDIA_DRIVERS_SOURCE) | \
		$(TAR) -O $(TAR_OPTIONS) - Linux_for_Tegra/nv_tegra/nvidia_drivers.tbz2 | \
	$(TAR) -j -C $(NVIDIA_DRIVERS_DIR) $(TAR_OPTIONS) -
endef

define NVIDIA_DRIVERS_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/lib/tegra/
	$(INSTALL) -d $(STAGING_DIR)/usr/lib/tegra-egl/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/tegra/*.so* $(STAGING_DIR)/usr/lib/tegra/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/tegra-egl/*.so* $(STAGING_DIR)/usr/lib/tegra-egl/
endef

define NVIDIA_DRIVERS_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/usr/lib/tegra/
	$(INSTALL) -d $(TARGET_DIR)/usr/lib/tegra-egl/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/tegra/*.so* $(TARGET_DIR)/usr/lib/tegra/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/tegra-egl/*.so* $(TARGET_DIR)/usr/lib/tegra-egl/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/xorg/modules/drivers/nvidia_drv.so $(TARGET_DIR)/usr/lib/xorg/modules/drivers/nvidia_drv.so
	ln -sf ../../../tegra/libglx.so $(TARGET_DIR)/usr/lib/xorg/modules/extensions/libglx.so

	$(INSTALL) -d $(TARGET_DIR)/lib/firmware
	$(INSTALL) -D -m 0644 $(@D)/lib/firmware/*.bin $(TARGET_DIR)/lib/firmware/
	$(INSTALL) -D -m 0644 $(@D)/lib/firmware/tegra_xusb_firmware $(TARGET_DIR)/lib/firmware/
	$(INSTALL) -d $(TARGET_DIR)/lib/firmware/tegra12x
	$(INSTALL) -D -m 0644 $(@D)/lib/firmware/tegra12x/*.{bin,fw} $(TARGET_DIR)/lib/firmware/tegra12x/
	$(INSTALL) -D -m 0644 $(@D)/etc/nv_tegra_release $(TARGET_DIR)/etc/nv_tegra_release
endef

$(eval $(generic-package))
