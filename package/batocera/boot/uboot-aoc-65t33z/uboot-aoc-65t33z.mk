################################################################################
#
# uboot files for AOC 65T33Z
#
################################################################################

UBOOT_AOC_65T33Z_VERSION = 2019.01
UBOOT_AOC_65T33Z_SOURCE =

define UBOOT_AOC_65T33Z_BUILD_CMDS
endef

define UBOOT_AOC_65T33Z_INSTALL_TARGET_CMDS
	mkdir -p $(BINARIES_DIR)/uboot-aoc-65t33z/
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/boot/uboot-aoc-65t33z/u-boot.bin.sd.bin.signed $(BINARIES_DIR)/uboot-aoc-65t33z/u-boot.bin.sd.signed
endef

$(eval $(generic-package))
