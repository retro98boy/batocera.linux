#!/bin/bash

# HOST_DIR = host dir
# BOARD_DIR = board specific dir
# BUILD_DIR = base dir/build
# BINARIES_DIR = images dir
# TARGET_DIR = target dir
# BATOCERA_BINARIES_DIR = batocera binaries sub directory

HOST_DIR=$1
BOARD_DIR=$2
BUILD_DIR=$3
BINARIES_DIR=$4
TARGET_DIR=$5
BATOCERA_BINARIES_DIR=$6

mkdir -p "${BATOCERA_BINARIES_DIR}/uboot-xiaoyi-pro"             || exit 1
cd "${BATOCERA_BINARIES_DIR}/uboot-xiaoyi-pro"
git clone "https://github.com/retro98boy/amlogic-fip-blobs.git"
cp amlogic-fip-blobs/cainiao-xiaoyi-pro/aml_autoscript .         || exit 1
cp amlogic-fip-blobs/cainiao-xiaoyi-pro/aml_autoscript.cmd .     || exit 1
cp amlogic-fip-blobs/cainiao-xiaoyi-pro/DDR_ENC.USB .            || exit 1
cp amlogic-fip-blobs/cainiao-xiaoyi-pro/env-autobootcmd .        || exit 1
cp amlogic-fip-blobs/cainiao-xiaoyi-pro/reserved-min-ept .       || exit 1
cp amlogic-fip-blobs/cainiao-xiaoyi-pro/u-boot.bin.ext .         || exit 1

mkdir -p "${BATOCERA_BINARIES_DIR}/boot/boot"     || exit 1
mkdir -p "${BATOCERA_BINARIES_DIR}/boot/extlinux" || exit 1

cp "${BINARIES_DIR}/Image"            "${BATOCERA_BINARIES_DIR}/boot/boot/linux"                       || exit 1
cp "${BINARIES_DIR}/initrd.lz4"       "${BATOCERA_BINARIES_DIR}/boot/boot/initrd.lz4"                  || exit 1
cp "${BINARIES_DIR}/rootfs.squashfs"  "${BATOCERA_BINARIES_DIR}/boot/boot/batocera.update"             || exit 1
cp "${BINARIES_DIR}/rufomaculata"     "${BATOCERA_BINARIES_DIR}/boot/boot/rufomaculata.update"         || exit 1
cp "${BINARIES_DIR}/meson-g12b-a311d-cainiao-xiaoyi-pro.dtb"  "${BATOCERA_BINARIES_DIR}/boot/boot/"    || exit 1

cp "${BOARD_DIR}/boot/extlinux.conf"                              "${BATOCERA_BINARIES_DIR}/boot/extlinux/" || exit 1
cp "${BATOCERA_BINARIES_DIR}/uboot-xiaoyi-pro/aml_autoscript"     "${BATOCERA_BINARIES_DIR}/boot/"          || exit 1
cp "${BATOCERA_BINARIES_DIR}/uboot-xiaoyi-pro/aml_autoscript.cmd" "${BATOCERA_BINARIES_DIR}/boot/"          || exit 1
cp "${BATOCERA_BINARIES_DIR}/uboot-xiaoyi-pro/u-boot.bin.ext"     "${BATOCERA_BINARIES_DIR}/boot/"          || exit 1

exit 0
