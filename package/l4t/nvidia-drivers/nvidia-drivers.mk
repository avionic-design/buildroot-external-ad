################################################################################
#
# l4t/nvidia-drivers
#
################################################################################

NVIDIA_DRIVERS_VERSION_MAJOR = 21
NVIDIA_DRIVERS_VERSION_MINOR = 3.0
NVIDIA_DRIVERS_VERSION = $(NVIDIA_DRIVERS_VERSION_MAJOR).$(NVIDIA_DRIVERS_VERSION_MINOR)
NVIDIA_DRIVERS_SOURCE = Tegra124_Linux_R$(NVIDIA_DRIVERS_VERSION)_armhf.tbz2
NVIDIA_DRIVERS_SITE = http://developer.download.nvidia.com/embedded/L4T/r$(NVIDIA_DRIVERS_VERSION_MAJOR)_Release_v$(NVIDIA_DRIVERS_VERSION_MINOR)/
NVIDIA_DRIVERS_LICENSE = custom
NVIDIA_DRIVERS_LICENSE_FILES = LICENSE
NVIDIA_DRIVERS_INSTALL_STAGING = YES
NVIDIA_DRIVERS_INSTALL_TARGET = YES

nvidia-drivers-stage2-tarball := nvidia_drivers.tbz2
nvidia-drivers-stage1-unpack-these := $(addprefix Linux_for_Tegra/nv_tegra/, \
	$(NVIDIA_DRIVERS_LICENSE_FILES) $(nvidia-drivers-stage2-tarball))

define NVIDIA_DRIVERS_EXTRACT_CMDS
	$(call suitable-extractor,$(NVIDIA_DRIVERS_SOURCE)) $(DL_DIR)/$(NVIDIA_DRIVERS_SOURCE) | \
	$(TAR) -C $(NVIDIA_DRIVERS_DIR) $(TAR_STRIP_COMPONENTS)=2 $(TAR_OPTIONS) - $(nvidia-drivers-stage1-unpack-these)
	$(call suitable-extractor,$(nvidia-drivers-stage2-tarball)) $(NVIDIA_DRIVERS_DIR)/$(nvidia-drivers-stage2-tarball) | \
	$(TAR) -C $(NVIDIA_DRIVERS_DIR) $(TAR_OPTIONS) -
	$(RM) $(NVIDIA_DRIVERS_DIR)/$(nvidia-drivers-stage2-tarball)
endef

define NVIDIA_DRIVERS_INSTALL_STAGING_CMDS
	$(INSTALL) -d $(STAGING_DIR)/usr/lib/tegra/
	$(INSTALL) -d $(STAGING_DIR)/usr/lib/tegra-egl/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/tegra/*.so* $(STAGING_DIR)/usr/lib/tegra/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/tegra-egl/*.so* $(STAGING_DIR)/usr/lib/tegra-egl/
	ln -sf libGL.so.1 $(STAGING_DIR)/usr/lib/tegra/libGL.so
	ln -sf libcuda.so.1.1 $(STAGING_DIR)/usr/lib/tegra/libcuda.so
	ln -sf libcuda.so.1.1 $(STAGING_DIR)/usr/lib/tegra/libcuda.so.1
endef

define NVIDIA_DRIVERS_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/usr/lib/tegra/
	$(INSTALL) -d $(TARGET_DIR)/usr/lib/tegra-egl/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/tegra/*.so* $(TARGET_DIR)/usr/lib/tegra/
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/arm-linux-gnueabihf/tegra-egl/*.so* $(TARGET_DIR)/usr/lib/tegra-egl/
	$(INSTALL) -d $(TARGET_DIR)/etc/profile.d
	$(INSTALL) -m 644 $(NVIDIA_DRIVERS_DIR)/set-ld-library-path.sh $(TARGET_DIR)/etc/profile.d
	$(INSTALL) -D -m 0755 $(@D)/usr/lib/xorg/modules/drivers/nvidia_drv.so $(TARGET_DIR)/usr/lib/xorg/modules/drivers/nvidia_drv.so
	ln -sf ../../../tegra/libglx.so $(TARGET_DIR)/usr/lib/xorg/modules/extensions/libglx.so
	ln -sf libGL.so.1 $(TARGET_DIR)/usr/lib/tegra/libGL.so
	ln -sf libcuda.so.1.1 $(TARGET_DIR)/usr/lib/tegra/libcuda.so
	ln -sf libcuda.so.1.1 $(TARGET_DIR)/usr/lib/tegra/libcuda.so.1

	$(INSTALL) -d $(TARGET_DIR)/lib/firmware
	$(INSTALL) -D -m 0644 $(@D)/lib/firmware/*.bin $(TARGET_DIR)/lib/firmware/
	$(INSTALL) -D -m 0644 $(@D)/lib/firmware/tegra_xusb_firmware $(TARGET_DIR)/lib/firmware/
	$(INSTALL) -d $(TARGET_DIR)/lib/firmware/tegra12x
	$(INSTALL) -D -m 0644 $(@D)/lib/firmware/tegra12x/*.{bin,fw} $(TARGET_DIR)/lib/firmware/tegra12x/
	$(INSTALL) -D -m 0644 $(@D)/etc/nv_tegra_release $(TARGET_DIR)/etc/nv_tegra_release
endef

$(eval $(generic-package))
