CUDA_DEBAYER_VERSION = v0.2.2
CUDA_DEBAYER_SITE = $(call github,avionic-design,cuda-debayer,$(CUDA_DEBAYER_VERSION))
CUDA_DEBAYER_LICENSE = GPLv2
CUDA_DEBAYER_AUTORECONF = YES

CUDA_DEBAYER_DEPENDENCIES += host-automake host-autoconf host-libtool \
			     host-cuda-cross-toolchain \
			     cuda libgl libglu libglew libfreeglut

CUDA_DEBAYER_CONF_ENV += NVCC=$(HOST_DIR)/usr/local/cuda/bin/nvcc \
			CXXFLAGS='$(TARGET_CXXFLAGS) -O2 -g'

CUDA_DEBAYER_CONF_OPTS += --with-opengl --without-opencv

$(eval $(autotools-package))
