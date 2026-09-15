################################################################################
#
# firmware-armbian
#
################################################################################
# Version: Commits on Sep 27, 2026
FIRMWARE_ARMBIAN_VERSION = 0c1c8566da756813ed1608462eb8e27f5f4ac733
FIRMWARE_ARMBIAN_SITE = https://github.com/retro98boy/armbian-firmware
FIRMWARE_ARMBIAN_SITE_METHOD = git

FIRMWARE_ARMBIAN_TARGET_DIR=$(TARGET_DIR)/lib/firmware/

define FIRMWARE_ARMBIAN_INSTALL_TARGET_CMDS
	mkdir -p $(FIRMWARE_ARMBIAN_TARGET_DIR)
	rsync -au --checksum --force $(@D)/ $(FIRMWARE_ARMBIAN_TARGET_DIR)/
endef

$(eval $(generic-package))
