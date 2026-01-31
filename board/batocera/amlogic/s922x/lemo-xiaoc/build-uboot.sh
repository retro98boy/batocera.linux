#!/bin/bash

HOST_DIR=$1
BOARD_DIR=$2
IMAGES_DIR=$3

# Download mainline U-Boot source
wget -O u-boot-2026.01.tar.gz "https://github.com/u-boot/u-boot/archive/refs/tags/v2026.01.tar.gz"
tar zxvf u-boot-2026.01.tar.gz
cd u-boot-2026.01

# Apply patches
PATCHES="${BR2_EXTERNAL_BATOCERA_PATH}/board/batocera/amlogic/s922x/patches/u-boot-2026.01/*.patch"
for patch in $PATCHES
do
    echo "Applying patch: $patch"
    patch -p1 < $patch
done

# Build u-boot.bin
make cainiao-lemo-xiaoc_defconfig
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
BLOBS_DIR=amlogic-fip-blobs/cainiao-lemo-xiaoc
EXTRACT_DIR="${BLOBS_DIR}/extract"

mkdir -p ../uboot-lemo-xiaoc
rm -rf "$EXTRACT_DIR" && mkdir "$EXTRACT_DIR"
dd if="${BLOBS_DIR}/mmcblk0boot0" of="${EXTRACT_DIR}/fip" bs=512 skip=1 conv=fsync,notrunc
./gxlimg/gxlimg -e "${EXTRACT_DIR}/fip" "$EXTRACT_DIR"

rm -f "${EXTRACT_DIR}/bl33.enc"
./gxlimg/gxlimg -t bl3x -s u-boot-2026.01/u-boot.bin "${EXTRACT_DIR}/bl33.enc"
./gxlimg/gxlimg \
    -t fip \
    --bl2 "${EXTRACT_DIR}/bl2.sign" \
    --ddrfw "${EXTRACT_DIR}/ddr4_1d.fw" \
    --ddrfw "${EXTRACT_DIR}/ddr4_2d.fw" \
    --ddrfw "${EXTRACT_DIR}/ddr3_1d.fw" \
    --ddrfw "${EXTRACT_DIR}/piei.fw" \
    --ddrfw "${EXTRACT_DIR}/lpddr4_1d.fw" \
    --ddrfw "${EXTRACT_DIR}/lpddr4_2d.fw" \
    --ddrfw "${EXTRACT_DIR}/diag_lpddr4.fw" \
    --ddrfw "${EXTRACT_DIR}/aml_ddr.fw" \
    --ddrfw "${EXTRACT_DIR}/lpddr3_1d.fw" \
    --bl30 "${EXTRACT_DIR}/bl30.enc" \
    --bl31 "${EXTRACT_DIR}/bl31.enc" \
    --bl33 "${EXTRACT_DIR}/bl33.enc" \
    --rev v3 ../uboot-lemo-xiaoc/u-boot.bin
