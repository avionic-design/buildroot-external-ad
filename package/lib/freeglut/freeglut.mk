FREEGLUT_VERSION = 2.8.1
FREEGLUT_SOURCE = freeglut-$(FREEGLUT_VERSION).tar.gz
FREEGLUT_SITE = http://downloads.sourceforge.net/project/freeglut/freeglut/$(FREEGLUT_VERSION)
FREEGLUT_LICENSE = MIT
FREEGLUT_INSTALL_STAGING = YES
FREEGLUT_INSTALL_TARGET = YES
FREEGLUT_DEPENDENCIES = libgl libglu

$(eval $(autotools-package))
