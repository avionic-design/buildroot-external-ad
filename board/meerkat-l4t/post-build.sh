#!/bin/sh

set -e

BUILDROOT_DIR=$PWD
cd "$TARGET_DIR"

#
# Record AD versions in os-release with an AD_ vendor prefix.
#

# The top-level buildroot Makefile creates /etc/os-release (overwriting
# it), then copies the rootfs overlays, then runs post-build scripts.
# Since we want to preserve the os-release info from buildroot, we can't
# put an os-release file in an overlay, and all fumbling with os-release
# is happening here.

# Clear existing entries first
sed -i /^AD_/d etc/os-release

# Kernel release version is temporarily stored in
# $BUILD_DIR/os-release.ad by the kernel package hooks
cat "$BUILD_DIR"/os-release.ad >> etc/os-release

# $BR2_VERSION_FULL carries commit info for untagged buildroot trees,
# includes -dirty info, and it's already saved to os-release as VERSION
# by buildroot, so we can skip that.

if [ -d "$BR2_EXTERNAL"/.git ]; then
	printf '%s="%s"\n' >> etc/os-release \
		AD_BR2_EXTERNAL_VERSION \
		"$(cd "$BR2_EXTERNAL" && git describe --dirty --long)"
fi

#
# Scrub files from the target that can be identified as having leaked
# from staging or host directories.
#
if test -d "./$STAGING_DIR"; then
	echo "Scrubbing bogus files from target that leaked from staging:"
	rm -rv "./$STAGING_DIR"
fi
if test -d "./$HOST_DIR"; then
	echo "Scrubbing bogus files from target that leaked from host:"
	rm -rv "./$HOST_DIR"
fi
if test -d "./$BASE_DIR"; then
	echo "Removing leftover directory tree ./$BASE_DIR"
	rmdir -p --ignore-fail-on-non-empty "$(readlink -f ./"$BASE_DIR")"
fi

#
# Enable ssh login with password
#
if [ -e etc/ssh/sshd_config ]
then
	echo "Enabling ssh root login with password."
	sed -ie '/^#PermitRootLogin/c\
PermitRootLogin yes
' etc/ssh/sshd_config
fi

#
# Add debugfs to /etc/fstab
#
if ! awk '$1 !~ /^#/ && $2 == "/sys/kernel/debug"' etc/fstab | grep -q .
then
	printf "debugfs\t\t/sys/kernel/debug\tdebugfs\tdefaults\t0\t0\n" \
		>> etc/fstab
fi
