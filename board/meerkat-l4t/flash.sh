#!/bin/sh
#
# meerkat-flash.sh: Helper script for flashing Meerkat SoM
#
# Copyright (C) 2015 Avionic Design GmbH
# Authors: Julian Scheel <julian@jusst.de>
#
# This file is part of the Avionic Design buildroot external overlay:
# buildroot-external-ad
#
# meerkat-flash.sh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with meerkat-flash.sh. If not, see <http://www.gnu.org/licenses/>.

print_usage() {
	echo "Usage: $0 [opts] diskimage"
	echo
	echo "diskimage must be a (ext4) diskdump, as generated by buildroot-external-ad"
	echo
	echo "The following options can be used"
	echo " -h --help       Print this help"
	echo " -d --device     Device to flash the image to (default: auto)"
	echo " -v --vendor     USB vendor id to use for autodetection (default: $vendor (NVidia))"
	echo " -p --product    USB product id to use for autodetection (default: $product (NVidia))"
	echo " -f --force      Force writing without asking for confirmation"
	echo " -P --keep-parttable Do not recreate the partition table"
}

warn() {
	echo "$0: $*" >&2
}

die() {
	[ "$*" ] && warn $*
	exit 1
}

check_depends() {
	local error=0

	type udevadm >/dev/null 2>&1 ||
		{ warn "Dependency error: udevadm could not be found.";
			error=1; }

	type dd >/dev/null 2>&1 &&
		type ddrescue >/dev/null 2>&1 ||
		{ warn "Dependency error:" \
			"Neither dd nor ddrescue could be found." && error=1; }

	type parted >/dev/null 2>&1 ||
		{ warn "Dependency error: parted could not be found" &&
			error=1; }

	type resize2fs >/dev/null 2>&1 ||
		{ warn "Dependency error: resize2fs could not be found" &&
			error=1; }

	[ $error -eq 1 ] && exit 1
}

flash_root_ddrescue() {
	local in="$1"
	local out="$2"
	[ -z "$in" ] && die "input file not specified"
	[ -z "$out" ] && die "output file not specified"

	ddrescue --force -D $in $out || die "Writing disk image failed"
}

flash_root_dd() {
	local in="$1"
	local out="$2"
	[ -z "$in" ] && die "input file not specified"
	[ -z "$out" ] && die "output file not specified"

	dd if=$in of=$out bs=4M || die "Writing disk image failed"
}

flash_root() {
	local out="$2"
	[ -b "$out" ] || die "output path $out not existing"

	if type ddrescue >/dev/null 2>&1; then
		echo "Using ddrescue for writing image to disk."
		flash_root_ddrescue "$@"
	elif type dd >/dev/null 2>&1; then
		echo "Using dd for writing image to disk."
		echo "Install ddrescue to see progress details"
		flash_root_dd "$@"
	else
		echo "No disk dump utility available"; exit 1;
	fi
}

resize_fs() {
	local part="$1"
	[ -b "$part" ] || die "$part is not a block device"

	resize2fs -p $part || die "Resizing filesystem to partition failed"
}

mkpart() {
	local disk="$1"
	local secs=0

	parted -s $disk mklabel gpt mkpart primary ext4 0% 100% ||
		die "Creating partition table failed"

	while ! [ -b ${disk}1 ]; do
		sleep 1
		[ $((++secs)) -lt 5 ] ||
			die "Timeout waiting for partition block device"
	done
}

detect_devices() {
	local vendor="$1"
	local product="$2"
	[ -z "$vendor" ] && die "vendor filter not specified"
	[ -z "$product" ] && die "product filter not specified"

	local device=""
	for disk in /sys/block/sd[a-z]; do
		ID_VENDOR_ID=
		ID_MODEL_ID=
		eval $(udevadm info -p $disk --query env --export)
		if [ "$ID_VENDOR_ID" = "$vendor" -a \
			"$ID_MODEL_ID" = "$product" ]; then

			# FIXME: Support returning a list of devices
			device=$DEVNAME
		fi
	done

	echo "$device"
}

# defaults
device=        # Autodetect
vendor="0955"  # NVidia
product="701a" # TK1 USB
partition=1
write_parttable=1

image=
force=0

# Check dependencies
check_depends

# Parse commandline optione
ARGS=$(getopt \
	-o hd:v:p:fP \
	-l "help,device:,vendor:,product:,force,keep-parttable" \
	-n $0 -- "$@") || die

eval set -- "$ARGS";

while true; do
	case "$1" in
		-h|--help)
			shift
			print_usage
			exit 1
			;;
		-d|--device)
			shift
			if [ -n "$1" ]; then
				device="$1"
				shift
			fi
			;;
		-v|--vendor)
			shift
			if [ -n "$1" ]; then
				vendor="$1"
				shift
			fi
			;;
		-p|--product)
			shift;
			if [ -n "$1" ]; then
				product="$1"
				shift
			fi
			;;
		-f|--force)
			shift
			force=1
			;;
		-P|--keep-parttable)
			shift
			write_parttable=0
			;;
		--)
			shift
			break
			;;
	esac
done

# Check input data
image=$1
[ -z "$image" ] && die "No image file specified"
[ ! -f "$image" ] && die "Image file not existant"

if [ -z "$device" ]; then
	echo "Searching for USB device $vendor:$product"
	device=$( detect_devices $vendor $product )
	[ "$device" ] && echo "Discovered matching device $device"
fi

[ -z $device ] && die "No device found or specified"

echo "Writing image $image to $device: $partition"
if [ $force -eq 0 ]; then
	echo "ATTENTION: Proceeding will wipe all data from $device."
	echo -n "Are you sure you want to proceed? (y/N) "
	read answer
	[ "$answer" != "y" ] && die "Aborting, nothing will be written"
fi
echo

step=1
if [ $write_parttable -eq 1 ]; then
	echo "Step $step: Writing partition table"
	mkpart $device
	echo "Step $step: done"
	step=$((step+1))
fi
echo

echo "Step $step: Writing image to disk"
flash_root $image $device$partition
echo "Step $step: done"
step=$((step+1))

echo "Step $step: Resizing filesystem to partition"
resize_fs $device$partition
echo "Step $step: done"

echo
echo "Target successfully flashed. Please reset the device to start booting."
