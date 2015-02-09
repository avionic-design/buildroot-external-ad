#!/bin/sh

IMAGES="${1}"

# Automatically build a uImage for each dtb
DTS=
for file in ${BINARIES_DIR}/*.dtb; do
	file=$(basename $file);
	DTS="${file%.*} ${DTS}";
done

echo "Build uImage files for device-trees: ${DTS}"

# FIXME: This is only required because old buildroot versions do not properly
# export $BR2_EXTERNAL to post-build scripts
BR2_EXTERNAL=${BR2_EXTERNAL:-../buildroot-external-ad/}

sed "s/IMAGES/$(echo ${IMAGES} | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" ${BR2_EXTERNAL}/board/meerkat-l4t/kernel_fdt.its.in > /tmp/kernel_fdt.its.in
for DT in ${DTS}; do
	echo "Building uImage with FDT ${DT} in ${IMAGES}"
	sed "s/DEVICETREE/$(echo ${DT} | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" /tmp/kernel_fdt.its.in > /tmp/kernel_fdt.its
	mkimage -f /tmp/kernel_fdt.its ${IMAGES}/uImage-${DT}
done
