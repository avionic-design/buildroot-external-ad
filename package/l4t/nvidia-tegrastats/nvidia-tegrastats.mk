NVIDIA_TEGRASTATS_VERSION_MAJOR = 21
NVIDIA_TEGRASTATS_VERSION_MINOR = 4.0
NVIDIA_TEGRASTATS_VERSION = $(NVIDIA_TEGRASTATS_VERSION_MAJOR).$(NVIDIA_TEGRASTATS_VERSION_MINOR)
NVIDIA_TEGRASTATS_SOURCE = Tegra124_Linux_R$(NVIDIA_TEGRASTATS_VERSION)_armhf.tbz2
NVIDIA_TEGRASTATS_SITE = http://developer.download.nvidia.com/embedded/L4T/r$(NVIDIA_TEGRASTATS_VERSION_MAJOR)_Release_v$(NVIDIA_TEGRASTATS_VERSION_MINOR)
NVIDIA_TEGRASTATS_LICENSE = custom
NVIDIA_TEGRASTATS_LICENSE_FILES = LICENSE
NVIDIA_TEGRASTATS_STRIP_COMPONENTS = 2

nvidia-tegrastats-stage2-tarball := nv_tools.tbz2
nvidia-tegrastats-stage1-unpack-these := $(addprefix Linux_for_Tegra/nv_tegra/, \
	$(NVIDIA_TEGRASTATS_LICENSE_FILES) $(nvidia-tegrastats-stage2-tarball))

define NVIDIA_TEGRASTATS_EXTRACT_CMDS
	$(call suitable-extractor,$(NVIDIA_TEGRASTATS_SOURCE)) $(DL_DIR)/$(NVIDIA_TEGRASTATS_SOURCE) | \
	$(TAR) -C $(NVIDIA_TEGRASTATS_DIR) --strip-components=$(NVIDIA_TEGRASTATS_STRIP_COMPONENTS) $(TAR_OPTIONS) - $(nvidia-tegrastats-stage1-unpack-these)
	$(call suitable-extractor,$(nvidia-tegrastats-stage2-tarball)) $(NVIDIA_TEGRASTATS_DIR)/$(nvidia-tegrastats-stage2-tarball) | \
	$(TAR) -C $(NVIDIA_TEGRASTATS_DIR) --strip-components=$(NVIDIA_TEGRASTATS_STRIP_COMPONENTS) $(TAR_OPTIONS) -
	$(RM) $(NVIDIA_TEGRASTATS_DIR)/$(nvidia-tegrastats-stage2-tarball)
endef

define NVIDIA_TEGRASTATS_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/tegrastats $(TARGET_DIR)/usr/bin/tegrastats
endef

$(eval $(generic-package))
