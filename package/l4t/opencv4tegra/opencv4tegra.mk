OPENCV4TEGRA_VERSION = 2.4.10.1
OPENCV4TEGRA_SITE = http://developer.download.nvidia.com/embedded/OpenCV/L4T_21.2
OPENCV4TEGRA_SOURCE = libopencv4tegra-repo_l4t-r21_$(OPENCV4TEGRA_VERSION)_armhf.deb
OPENCV4TEGRA_LICENSE = EULA
OPENCV4TEGRA_LICENSE_FILES = $(notdir $(opencv4tegra-tempdir-repo-root))/usr/share/doc/libopencv4tegra-repo/copyright
OPENCV4TEGRA_REDISTRIBUTE = NO
OPENCV4TEGRA_DEPENDENCIES = cuda libpng12 jpeg libjpeg tiff jasper ffmpeg12 \
			    libgtk2 zlib

OPENCV4TEGRA_INSTALL_TARGET = YES
OPENCV4TEGRA_INSTALL_STAGING = YES

opencv4tegra-package-basenames := libopencv4tegra

opencv4tegra-target-package-names := $(opencv4tegra-package-basenames)
opencv4tegra-staging-package-names := $(addsuffix -dev,$(opencv4tegra-package-basenames))

opencv4tegra-tempdir-repo-root = $(OPENCV4TEGRA_DIR)/repo
opencv4tegra-tempdir-repo      = $(opencv4tegra-tempdir-repo-root)/var/opencv4tegra-repo

opencv4tegra-tempdir-target  = $(OPENCV4TEGRA_DIR)/for-target
opencv4tegra-tempdir-staging = $(OPENCV4TEGRA_DIR)/for-staging

define opencv4tegra-unpack-debfile-to
	ar p $(1) data.tar.gz | $(TAR) -C '$(2)' -z $(TAR_OPTIONS) -
endef

define opencv4tegra-unpack-debian-packages-by-name-to
	mkdir -p '$(2)'
	set -e; cd '$(opencv4tegra-tempdir-repo)' && \
	for packname in $(1); do \
		$(call opencv4tegra-unpack-debfile-to,$${packname}_$(OPENCV4TEGRA_VERSION)*.deb,$(2)); \
	done
endef

define OPENCV4TEGRA_EXTRACT_CMDS
	mkdir -p '$(opencv4tegra-tempdir-repo-root)'
	$(call opencv4tegra-unpack-debfile-to,$(DL_DIR)/$(OPENCV4TEGRA_SOURCE),$(opencv4tegra-tempdir-repo-root))
	$(call opencv4tegra-unpack-debian-packages-by-name-to,$(opencv4tegra-target-package-names),$(opencv4tegra-tempdir-target))
	$(call opencv4tegra-unpack-debian-packages-by-name-to,$(opencv4tegra-staging-package-names),$(opencv4tegra-tempdir-staging))
endef

define opencv4tegra-install-from-to
	cd '$(1)' && find . \
		-path ./usr/share/lintian -prune -o -print0 | \
		cpio -p0dum '$(2)'
endef

define OPENCV4TEGRA_INSTALL_TARGET_CMDS
	$(call opencv4tegra-install-from-to,$(opencv4tegra-tempdir-target),$(TARGET_DIR))
endef

define OPENCV4TEGRA_INSTALL_STAGING_CMDS
	$(call opencv4tegra-install-from-to,$(opencv4tegra-tempdir-target),$(STAGING_DIR))
	$(call opencv4tegra-install-from-to,$(opencv4tegra-tempdir-staging),$(STAGING_DIR))
endef

$(eval $(generic-package))
