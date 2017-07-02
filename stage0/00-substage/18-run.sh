#!/bin/bash -e

unmount_image "$IMG_FILE"

rm -f "$IMG_FILE"

BOOT_SIZE=$(du --apparent-size -s "$BOOTFS_DIR" --block-size=1 | cut -f 1)
TOTAL_SIZE=$(du --apparent-size -s "$ROOTFS_DIR" --exclude var/cache/apt/archives --block-size=1 | cut -f 1)

IMG_SIZE=$((BOOT_SIZE + TOTAL_SIZE + (800 * 1024 * 1024)))

truncate -s $IMG_SIZE "$IMG_FILE"

fdisk -H 255 -S 63 "$IMG_FILE" <<EOF
o
n


8192
+$((BOOT_SIZE * 2 / 512))
p
t
c
n


8192


p
w
EOF

PARTED_OUT=$(parted -s "$IMG_FILE" unit b print)

BOOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^ 1' | xargs echo -n \
| cut -d" " -f 2 | tr -d B)
BOOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^ 1' | xargs echo -n \
| cut -d" " -f 4 | tr -d B)
ROOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^ 2' | xargs echo -n \
| cut -d" " -f 2 | tr -d B)
ROOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^ 2' | xargs echo -n \
| cut -d" " -f 4 | tr -d B)

BOOT_DEV=$(losetup --show -f -o $BOOT_OFFSET --sizelimit $BOOT_LENGTH "$IMG_FILE")
ROOT_DEV=$(losetup --show -f -o $ROOT_OFFSET --sizelimit $ROOT_LENGTH "$IMG_FILE")

mkdosfs -n boot -F 32 -v $BOOT_DEV > /dev/null
mkfs.ext4 -O ^huge_file $ROOT_DEV > /dev/null

mkdir -p "$ROOTFS_DIR"
mount -v $ROOT_DEV "$ROOTFS_DIR" -t ext4

mkdir -p "$BOOTFS_DIR"
mount -v $BOOT_DEV "$BOOTFS_DIR" -t vfat

if [ -e ${ROOTFS_DIR}/etc/ld.so.preload ]; then
	mv ${ROOTFS_DIR}/etc/ld.so.preload ${ROOTFS_DIR}/etc/ld.so.preload.disabled
fi

if [ ! -x ${ROOTFS_DIR}/usr/bin/qemu-arm-static ]; then
	cp /usr/bin/qemu-arm-static ${ROOTFS_DIR}/usr/bin/
fi