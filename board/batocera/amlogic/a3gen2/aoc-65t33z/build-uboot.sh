#!/bin/bash

HOST_DIR=$1
BOARD_DIR=$2
IMAGES_DIR=$3

# Just copy working blob until better solution
mkdir -p ../uboot-aoc-65t33z
cp "${IMAGES_DIR}/uboot-aoc-65t33z/u-boot.bin.sd.signed" ../uboot-aoc-65t33z/
