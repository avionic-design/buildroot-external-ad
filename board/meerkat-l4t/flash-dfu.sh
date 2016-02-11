#!/bin/sh

die() {
	echo $1
	echo
	usage
	exit 1
}

usage() {
	echo "Usage: $0 [options] <partition1:image1> ... <partitionN:imageN>"
	echo ""
	echo "Options:"
	echo "	-b bct-file		bct file to run flasher with.  (default=<output-dir>/images/meerkat_rev02.bct"
	echo "	-f u-boot-flasher	u-boot flasher image to use.  (default=<output-dir>/images/u-boot-flasher.bin"
	echo "	-m msg-file-base	basename for tegrarcm presigned msg files"
	echo "	-o buildroot-output	output directory of buildroot, used to autoselect images and access utilities."
	echo "	-p pkc-file		key file to use for signed communication (default=none)"
	echo "	-r rootfs		rootfs image to write.  (default=<output-dir>/images/rootfs.ext4"
	echo "	-u usb device path	USB device path to use for flashing."
}

wait_usb_path() {
	USB_PATH=$1
	VENDOR=$2
	PRODUCT=$3
	FOUND=0

	while [ ${FOUND} -eq 0 ]; do
		VENDOR_ID=$(cat /sys/bus/usb/devices/${USB_PATH}/idVendor)
		PRODUCT_ID=$(cat /sys/bus/usb/devices/${USB_PATH}/idProduct)

		if [ "x${VENDOR_ID}" = "x${VENDOR}" ] && [ "x${PRODUCT_ID}" = "x${PRODUCT}" ]; then
			FOUND=1
		else
			sleep 1
		fi
	done
}

load_flasher() {
	# Step 1 flash u-boot and poot it in DFU mode
	if [ "x${USB_PATH}" = "x" ]; then
		lsusb | grep -q 0955:7740
		if [ $? -ne 0 ]; then
			echo "Please put Tegra into Recovery Mode and connect to USB."
			echo ""
			echo ""
			echo "-------------------------------------"
			echo "Waiting for Tegra in Recovery Mode..."
			until lsusb -d 0955:7740 >/dev/null; do
				sleep 1
			done
			echo "-------------------------------------"
		fi
	else
		echo "Wait for Tegra in Recovery Mode on USB Port ${USB_PATH}"
		wait_usb_path ${USB_PATH} 0955 7740
	fi
	echo ""
	USB_ARG=
	[ "x${USB_PATH}" != "x" ] && USB_ARG=--usb-port-path="${USB_PATH}"
	[ "x${PKC_FILE}" != "x" ] && PKC_ARG=--pkc="${PKC_FILE}"
	[ "x${MSG_FILE}" != "x" ] && MSG_ARG0=--download-signed-msgs && MSG_ARG1=--signed-msgs-file="${MSG_FILE}"
	echo "Starting u-boot-flasher ($USB_ARG)..."
	tegrarcm ${USB_ARG} \
		${PKC_ARG} \
		${MSG_ARG0} \
		${MSG_ARG1} \
		--bct "${BCT}" \
		--bootloader "${FLASHER}" \
		--loadaddr=0x80108000 \
		--usb-timeout=5000 || die "Failed to start u-boot-flasher"
}

load_partition() {
	# Step 2 flash a filesystem
	# Wait for device to appear
	if [ "x${USB_PATH}" = "x" ]; then
		lsusb | grep -q 0955:701a
		if [ $? -ne 0 ]; then
			echo ""
			echo ""
			echo "-------------------------------------"
			echo "Waiting for DFU device to appear..."
			lsusb | grep -q 0955:701a
			while [ $? -ne 0 ]; do
				sleep 1
				lsusb | grep -q 0955:701a
			done
			echo "-------------------------------------"
		fi
	else
		echo "Wait for Tegra in DFU Mode on USB Port ${USB_PATH}"
		wait_usb_path ${USB_PATH} 0955 701a
	fi
	echo ""
	USB_ARG=
	[ "x${USB_PATH}" != "x" ] && USB_ARG="--path ${USB_PATH}"
	echo "Flashing filesystem ${FILE} to ${PARTITION} ($USB_ARG)..."
	time dfu-util -d 0955:701a ${USB_ARG} -D \
		$2 -a $1 $3 || die "Failed to flash filesystem $1 to $2"
}

BCT=""
FLASHER=""
USB_PATH=""
PKC_FILE=""
while getopts ":f:b:m:o:p:u:h" opt; do
	case $opt in
		b)
			BCT=$OPTARG
			;;
		f)
			FLASHER=$OPTARG
			;;
		m)
			MSG_FILE=$OPTARG
			;;
		o)
			OUTPUT=$OPTARG
			;;
		p)
			PKC_FILE=$OPTARG
			;;
		u)
			USB_PATH=$OPTARG
			;;
		h)
			usage
			exit 0
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done
shift "$((OPTIND-1))"

if [ -d "${OUTPUT}" ]; then
	export PATH=$OUTPUT/host/usr/bin:$PATH

	if [ "x${BCT}" = "x" ]; then
		BCT="${OUTPUT}"/images/meerkat_rev02.bct
		# Use signed bct if available
		[ -e "${BCT}".signed ] && BCT="${BCT}".signed
	fi

	if [ "x${MSG_FILE}" = "x" ]; then
		[ -e "${OUTPUT}"/images/tegrarcm-msgs.qry ] && \
			MSG_FILE="${OUTPUT}"/images/tegrarcm-msgs
	fi

	if [ "x${FLASHER}" = "x" ]; then
		FLASHER="${OUTPUT}"/images/u-boot-flasher.bin
	fi
fi

[ -f "${BCT}" ] || die "bct has to be specified"
[ -f "${FLASHER}" ] || die "flasher has to be specified"

load_flasher
if [ $# -eq 0 ]; then
	echo "Flashing default rootfs"
	PARTITION=rootfs
	FILE="${OUTPUT}"/images/rootfs.ext4

	load_partition "${PARTITION}" "${FILE}" -R
fi

while [ $# -gt 0 ]; do
	PARTITION=$(echo "$1" | awk -F':' '{print $1}')
	FILE=$(echo "$1" | awk -F':' '{print $2}')
	# Search in output directory
	[ -f "${FILE}" ] || FILE="${OUTPUT}"/"${FILE}"
        [ -f "${FILE}" ] || die "filesystem has to be specified"
	[ "x${PARTITION}" = "x" ] && die "partition has to be specified"
	echo ""
	echo ""

	[ $# -eq 1 ] && RESET=-R
	load_partition "${PARTITION}" "${FILE}" ${RESET}

	shift 1
done
