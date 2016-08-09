include $(sort $(wildcard $(BR2_EXTERNAL)/package/*/*/*.mk))

# Make sure enlightenment is built with udisks support
ifeq ($(BR2_PACKAGE_UDISKS),y)
ENLIGHTENMENT_DEPENDENCIES += udisks
endif
