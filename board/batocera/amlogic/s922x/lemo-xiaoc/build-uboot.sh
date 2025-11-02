#!/bin/bash

HOST_DIR=$1
BOARD_DIR=$2
IMAGES_DIR=$3

# Download mainline U-Boot source
wget -O u-boot-2025.04.tar.gz "https://github.com/u-boot/u-boot/archive/refs/tags/v2025.04.tar.gz"
tar zxvf u-boot-2025.04.tar.gz
cd u-boot-2025.04

# Apply patches
PATCHES="${BR2_EXTERNAL_BATOCERA_PATH}/board/batocera/amlogic/s922x/patches/u-boot-2025.04/*.patch"
for patch in $PATCHES
do
    echo "Applying patch: $patch"
    patch -p1 < $patch
done

# Build u-boot.bin
make cainiao-lemo-xiaoc_defconfig
CROSS_COMPILE="${HOST_DIR}/bin/aarch64-buildroot-linux-gnu-" make -j$(nproc)
cd ..

# Fetch aml_encrypt_g12b
git clone "https://github.com/LibreELEC/amlogic-boot-fip.git"
AML_ENCRYPT="amlogic-boot-fip/khadas-vim3/aml_encrypt_g12b"

# Fetch gxlimg source then compile it
git clone "https://github.com/repk/gxlimg.git"
cd gxlimg
make -j$(nproc)
cd ..

# Fetch device vendor FIP
git clone "https://github.com/retro98boy/amlogic-fip-blobs.git"

# repack vendor FIP with mainlien u-boot.bin
BLOBS_DIR=amlogic-fip-blobs/cainiao-lemo-xiaoc
EXTRACT_DIR="${BLOBS_DIR}/extract"

mkdir -p ../uboot-lemo-xiaoc
rm -f "${EXTRACT_DIR}/bl33.enc"
# The current version of gxlimg has a problem with the handling of bl3x,
# which may cause the produced fip to fail to boot.
# see https://github.com/repk/gxlimg/issues/19
# ./gxlimg/gxlimg -t bl3x -s u-boot-2025.04/u-boot.bin "${EXTRACT_DIR}/bl33.enc"
"$AML_ENCRYPT" --bl3sig \
    --input u-boot-2025.04/u-boot.bin \
    --output "${EXTRACT_DIR}/bl33.enc" \
    --level v3 --type bl33
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
