################################################################################
#
# firmware-armbian
#
################################################################################
# Version: Commits on Oct 15, 2026
FIRMWARE_ARMBIAN_VERSION = 9ac6997404ad53e34e46211e8fa153a41e5fa3f9
FIRMWARE_ARMBIAN_SITE = https://github.com/retro98boy/armbian-firmware
FIRMWARE_ARMBIAN_SITE_METHOD = git

FIRMWARE_ARMBIAN_TARGET_DIR=$(TARGET_DIR)/lib/firmware/

define FIRMWARE_ARMBIAN_INSTALL_TARGET_CMDS
	mkdir -p $(FIRMWARE_ARMBIAN_TARGET_DIR)
	rsync -au --checksum --force $(@D)/ $(FIRMWARE_ARMBIAN_TARGET_DIR)/
endef

$(eval $(generic-package))
