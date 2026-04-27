################################################################################
#
# uboot files for CoreLab TVPro
#
################################################################################

UBOOT_CORELAB_TVPRO_VERSION = 2019.01
UBOOT_CORELAB_TVPRO_SOURCE =

define UBOOT_CORELAB_TVPRO_BUILD_CMDS
endef

define UBOOT_CORELAB_TVPRO_INSTALL_TARGET_CMDS
	mkdir -p $(BINARIES_DIR)/uboot-corelab-tvpro/
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/boot/uboot-corelab-tvpro/u-boot.bin.sd.bin.signed $(BINARIES_DIR)/uboot-corelab-tvpro/u-boot.bin.sd.signed
endef

$(eval $(generic-package))
