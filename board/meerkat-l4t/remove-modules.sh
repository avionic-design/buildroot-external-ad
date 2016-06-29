#!/bin/sh

echo "Removing kernel modules from target filesystem..."
rm -rf ${TARGET_DIR}/lib/modules/*
