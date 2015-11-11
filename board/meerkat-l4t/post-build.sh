#!/bin/sh

set -e

cd "$TARGET_DIR"

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
	rmdir -p --ignore-fail-on-non-empty "./$BASE_DIR"
fi

echo "Enabling ssh root login with password."
sed -ie '/^#PermitRootLogin/c\
PermitRootLogin yes
' etc/ssh/sshd_config
