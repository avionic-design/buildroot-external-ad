CUDA_SAMPLES_VERSION = 6.5
CUDA_SAMPLES_SITE = http://developer.download.nvidia.com/embedded/jetson/TK1/2014-03-24
CUDA_SAMPLES_SOURCE = CUDA_SDK_Samples.tgz
CUDA_SAMPLES_LICENSE = EULA
CUDA_SAMPLES_REDISTRIBUTE = NO
CUDA_SAMPLES_DEPENDENCIES = cuda

cuda-samples-bindir = /usr/local/cuda-$(CUDA_SAMPLES_VERSION)/samples/bin

define CUDA_SAMPLES_INSTALL_TARGET_CMDS
	$(INSTALL) -d '$(TARGET_DIR)$(cuda-samples-bindir)'
	$(TAR) -C '$(@D)' -cO . | \
		$(TAR) -C '$(TARGET_DIR)$(cuda-samples-bindir)' $(TAR_OPTIONS) -
endef

$(eval $(generic-package))
