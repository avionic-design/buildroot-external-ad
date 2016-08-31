#!/bin/sh

set -e

cd "$TARGET_DIR"

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
