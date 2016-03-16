#!/bin/sh

warn() {
	echo "$0: $*" >&2
}

die() {
	[ "$*" ] && warn $*
	# If we mounted the target unmount it
	[ -n "$MOUNTPOINT" ] && mount | grep -q -w "$MOUNTPOINT" && \
		umount "$MOUNTPOINT"
	exit 1
}

DEV="$1"
IMAGES="$2"
PARTITION=1
MOUNTPOINT=

if [ ! -b "$DEV" -o ! -d "$IMAGES" ] ; then
	echo "Usage: $(basename $0) DEVICE IMAGES"
	echo "  DEVICE: Device to use, for example /dev/sdb"
	echo "  IMAGES: Directory with the initrd, zImage and DTBs"
	exit 1
fi

echo "Writing partition table to $DEV"
parted -a optimal -s "$DEV" mklabel gpt mkpart updater ext4 0% 100% || \
	die "Failed to write partition table to $DEV"
udevadm settle -t 5 || \
	die "Timeout waiting for partition block device"

PARTITION="$(readlink -e /dev/disk/by-partlabel/updater)"

[ -b "$PARTITION" ] || \
	die "Failed to get updater partition"

[ "${PARTITION#$DEV}" != "$PARTITION" ] || \
	die "The updater partition $PARTITION is not on device $DEV"

# Check if an automounter already mounted the target device
if mount | grep -q -w "$PARTITION" ; then
	umount "$PARTITION" || \
		die "Failed to unmount $PARTITION"
fi

echo "Creating filesystem on $PARTITION"
mkfs.ext4 -q -L updater "$PARTITION" || \
	die "Failed to create filesystem on $PARTITION"

[ -n "$MOUNTPOINT" ] || MOUNTPOINT=/tmp/updater

mkdir -p "$MOUNTPOINT" || \
	die "Failed to create mount point $MOUNTPOINT"
mount "$PARTITION" "$MOUNTPOINT" || \
	die "Failed to mount $PARTITION at $MOUNTPOINT"

echo "Copying updater system"
mkdir -p "$MOUNTPOINT/boot/extlinux" || \
	die "Failed to create updater directories"

cp "$IMAGES/rootfs.cpio.gz" "$IMAGES/zImage" "$IMAGES/"*.dtb \
	"$MOUNTPOINT/boot" || \
	die "Failed to copy updater OS"

cat <<EOF > $MOUNTPOINT/boot/extlinux/extlinux.conf
menu title Meerkat Updater

timeout 10
default UPDATER

label UPDATER
	menu label "Meerkat Updater"
	kernel /boot/zImage
	fdtdir /boot
	initrd /boot/rootfs.cpio.gz
	append console=ttyS0,115200
EOF

umount "$PARTITION"
