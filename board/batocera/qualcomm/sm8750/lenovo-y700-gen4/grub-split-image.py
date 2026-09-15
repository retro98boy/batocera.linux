#!/usr/bin/env python3
"""Build 4096-byte UFS partition images for the Lenovo Y700 Gen4."""

import gzip
import hashlib
import os
from pathlib import Path
import re
import struct
import subprocess
import sys
import tempfile
import uuid
import zlib


GPT_LBA_BYTES = 512
UFS_SECTOR_BYTES = 4096
BUFFER_BYTES = 1024 * 1024
DISK_NAME = re.compile(r"batocera-sm8750-lenovo-y700-gen4-[0-9.]+-[0-9]{8}\.img\.gz")

# Lenovo Y700 Gen4 images are flashed into existing LUN0 GPT partitions, not as a whole disk.
# Its UFS exposes 4096-byte logical sectors. A 512-byte FAT boot partition fails:
# FAT-fs (sda17): logical sector size too small for device (logical sector size = 512)
# Reformat only the split boot/userdata images; leave the full GPT image unchanged.


def partitions_in_gpt(disk):
    disk.seek(GPT_LBA_BYTES)
    header = disk.read(GPT_LBA_BYTES)
    if len(header) != GPT_LBA_BYTES or header[:8] != b"EFI PART":
        raise ValueError("missing 512-byte-LBA GPT header")

    header_length, header_checksum = struct.unpack_from("<II", header, 12)
    if not 92 <= header_length <= GPT_LBA_BYTES:
        raise ValueError("invalid GPT header length")
    checked_header = bytearray(header[:header_length])
    checked_header[16:20] = b"\0" * 4
    if zlib.crc32(checked_header) != header_checksum:
        raise ValueError("GPT header checksum mismatch")

    usable_start, usable_end = struct.unpack_from("<QQ", header, 40)
    table_lba, entry_count, entry_bytes, table_checksum = struct.unpack_from("<QIII", header, 72)
    if (table_lba < 2 or usable_start > usable_end or entry_count < 2
            or entry_bytes < 128 or entry_bytes % 8 or entry_count * entry_bytes > 16 * 1024 * 1024):
        raise ValueError("invalid GPT table geometry")
    disk.seek(table_lba * GPT_LBA_BYTES)
    table = disk.read(entry_count * entry_bytes)
    if len(table) != entry_count * entry_bytes or zlib.crc32(table) != table_checksum:
        raise ValueError("GPT table checksum mismatch")

    locations = {}
    for slot, name in enumerate(("boot", "userdata")):
        entry = table[slot * entry_bytes:(slot + 1) * entry_bytes]
        first_lba, last_lba = struct.unpack_from("<QQ", entry, 32)
        if entry[:16] == b"\0" * 16 or not usable_start <= first_lba <= last_lba <= usable_end:
            raise ValueError(f"invalid {name} partition")
        start = first_lba * GPT_LBA_BYTES
        length = (last_lba - first_lba + 1) * GPT_LBA_BYTES
        if start % UFS_SECTOR_BYTES or length % UFS_SECTOR_BYTES:
            raise ValueError(f"{name} partition is not 4096-byte aligned")
        locations[name] = (start, length)
    boot_start, boot_length = locations["boot"]
    if boot_start + boot_length > locations["userdata"][0]:
        raise ValueError("boot and userdata partitions overlap")
    return locations


def source_filesystems(disk, locations):
    disk.seek(locations["boot"][0])
    boot = disk.read(2048)
    if (boot[82:90] != b"FAT32   " or boot[71:82].rstrip() != b"BATOCERA"
            or struct.unpack_from("<H", boot, 11)[0] not in (512, 1024, 2048, 4096)):
        raise ValueError("boot partition is not BATOCERA FAT32")
    fat_serial = f"{struct.unpack_from('<I', boot, 67)[0]:08x}"

    disk.seek(locations["userdata"][0] + 1024)
    ext4 = disk.read(1024)
    if ext4[56:58] != b"\x53\xef" or ext4[120:136].rstrip(b"\0") != b"SHARE":
        raise ValueError("userdata partition is not SHARE ext4")
    ext4_uuid = str(uuid.UUID(bytes=ext4[104:120]))
    return fat_serial, ext4_uuid


def run(command):
    subprocess.run([str(arg) for arg in command], check=True)


def create_partition(name, path, length, filesystem_id, host, boot_files, userdata_files):
    with path.open("wb") as image:
        image.truncate(length)

    if name == "boot":
        run([host / "sbin/mkfs.fat", "-F", "32", "-n", "BATOCERA",
             "-S", str(UFS_SECTOR_BYTES), "-s", "4", "-i", filesystem_id, path])
        for item in sorted(boot_files.iterdir()):
            run([host / "bin/mcopy", "-s", "-i", path, item, "::"])
    else:
        run([host / "sbin/mkfs.ext4", "-F", "-m", "0", "-b", str(UFS_SECTOR_BYTES),
             "-L", "SHARE", "-U", filesystem_id, "-d", userdata_files, path])

    with path.open("rb") as image:
        data = image.read(2048)
    if name == "boot":
        if (struct.unpack_from("<H", data, 11)[0] != UFS_SECTOR_BYTES
                or data[71:82].rstrip() != b"BATOCERA"
                or f"{struct.unpack_from('<I', data, 67)[0]:08x}" != filesystem_id):
            raise ValueError("reformatted boot image has the wrong FAT metadata")
    else:
        ext4 = data[1024:2048]
        if (ext4[56:58] != b"\x53\xef" or 1024 << struct.unpack_from("<I", ext4, 24)[0] != UFS_SECTOR_BYTES
                or ext4[120:136].rstrip(b"\0") != b"SHARE"
                or str(uuid.UUID(bytes=ext4[104:120])) != filesystem_id):
            raise ValueError("reformatted userdata image has the wrong ext4 metadata")


def compress_and_hash(source, destination):
    md5 = hashlib.md5()
    sha256 = hashlib.sha256()
    with source.open("rb") as raw, destination.open("wb") as file:
        with gzip.GzipFile(filename="", mode="wb", fileobj=file, mtime=0) as compressed:
            while chunk := raw.read(BUFFER_BYTES):
                compressed.write(chunk)
    with destination.open("rb") as file:
        while chunk := file.read(BUFFER_BYTES):
            md5.update(chunk)
            sha256.update(chunk)
    return md5.hexdigest(), sha256.hexdigest()


def main(images):
    board_images = images / "batocera/images/lenovo-y700-gen4"
    if not board_images.is_dir():
        return
    disk_images = [path for path in board_images.iterdir() if DISK_NAME.fullmatch(path.name)]
    if len(disk_images) != 1:
        raise ValueError(f"expected one Lenovo Y700 Gen4 disk image, found {len(disk_images)}")

    host = Path(os.environ["HOST_DIR"])
    # The generic post-image hook removes genimage's raw files; these are their input trees.
    boot_files = images / "batocera/boot_lenovo-y700-gen4"
    userdata_files = Path(os.environ["TARGET_DIR"]) / "userdata"
    if not boot_files.is_dir() or not userdata_files.is_dir():
        raise ValueError("Lenovo Y700 Gen4 boot or userdata source directory is missing")

    disk_image = disk_images[0]
    with gzip.open(disk_image, "rb") as disk:
        locations = partitions_in_gpt(disk)
        fat_serial, ext4_uuid = source_filesystems(disk, locations)
        while disk.read(BUFFER_BYTES):
            pass  # Check the source gzip trailer before publishing any image.

    prefix = disk_image.name.removesuffix(".img.gz")
    with tempfile.TemporaryDirectory(dir=board_images, prefix=".y700-split-") as work:
        stage = Path(work)
        exports = []
        for name, identifier in (("boot", fat_serial), ("userdata", ext4_uuid)):
            raw = stage / f"{name}.img"
            packed = stage / f"{name}.img.gz"
            create_partition(name, raw, locations[name][1], identifier, host, boot_files, userdata_files)
            md5, sha256 = compress_and_hash(raw, packed)
            exports.append((packed, board_images / f"{prefix}.{name}.img.gz", md5, sha256))

        for packed, destination, md5, sha256 in exports:
            os.replace(packed, destination)
            for algorithm, digest in (("md5", md5), ("sha256", sha256)):
                destination.with_name(f"{destination.name}.{algorithm}").write_text(f"{digest}\n")
                with (images / "batocera" / f"{algorithm.upper()}SUMS").open("a") as manifest:
                    manifest.write(f"{digest}  {destination.name}\n")
            print(f"created {destination}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: grub-split-image.py BINARIES_DIR")
    main(Path(sys.argv[1]))
