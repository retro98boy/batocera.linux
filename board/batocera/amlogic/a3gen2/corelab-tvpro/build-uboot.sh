#!/bin/bash

HOST_DIR=$1
BOARD_DIR=$2
IMAGES_DIR=$3

# Just copy working blob until better solution
mkdir -p ../uboot-corelab-tvpro
cp "${IMAGES_DIR}/uboot-corelab-tvpro/u-boot.bin.sd.signed" ../uboot-corelab-tvpro/
