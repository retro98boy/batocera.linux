#!/bin/bash

HOST_DIR=$1
BOARD_DIR=$2
IMAGES_DIR=$3

# Download mainline U-Boot source
wget -O u-boot-2026.01.tar.gz "https://github.com/u-boot/u-boot/archive/refs/tags/v2026.01.tar.gz"
tar zxvf u-boot-2026.01.tar.gz
cd u-boot-2026.01

# Apply patches
PATCHES="${BR2_EXTERNAL_BATOCERA_PATH}/board/batocera/amlogic/s905/patches/u-boot-2026.01/*.patch"
for patch in $PATCHES
do
    echo "Applying patch: $patch"
    patch -p1 < $patch
done

# Build u-boot.bin
make bestv-r3300-l_defconfig
CROSS_COMPILE="${HOST_DIR}/bin/aarch64-buildroot-linux-gnu-" make -j$(nproc)
cd ..

# Fetch gxlimg source then compile it
git clone "https://github.com/retro98boy/gxlimg.git"
cd gxlimg
git reset --hard fde6a3dd0e13875a5b219389c0a6137616eaebdb
make -j$(nproc)
cd ..

# Fetch device vendor FIP
git clone "https://github.com/retro98boy/amlogic-fip-blobs.git"

# repack vendor FIP with mainlien u-boot.bin
BLOBS_DIR=amlogic-fip-blobs/bestv-r3300-l
EXTRACT_DIR="${BLOBS_DIR}/extract"

mkdir -p ../uboot-r3300-l
rm -rf "$EXTRACT_DIR" && mkdir "$EXTRACT_DIR"
./gxlimg/gxlimg -e "${BLOBS_DIR}/bootloader.PARTITION" "$EXTRACT_DIR"

rm -f "${EXTRACT_DIR}/bl33.enc"
./gxlimg/gxlimg -t bl3x -c u-boot-2026.01/u-boot.bin "${EXTRACT_DIR}/bl33.enc"
./gxlimg/gxlimg \
    -t fip \
    --bl2 "${EXTRACT_DIR}/bl2.sign" \
    --bl30 "${EXTRACT_DIR}/bl30.enc" \
    --bl301 "${EXTRACT_DIR}/bl301.enc" \
    --bl31 "${EXTRACT_DIR}/bl31.enc" \
    --bl33 "${EXTRACT_DIR}/bl33.enc" \
    ../uboot-r3300-l/u-boot.bin
