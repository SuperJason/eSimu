#!/bin/bash

if [  ! -n "$ESIMU_ROOT" ]; then
	ESIMU_ROOT=$(cd "$(dirname "$0")/../../";pwd)
fi

source $ESIMU_ROOT/eSimu/scripts/envsetup.sh

cd $ESIMU_ROOT/out/

# Start qemu
gnome-terminal -x bash -c \
	"./qemu-system-aarch64 \
		-M virt \
		-cpu cortex-a53 \
		-m 1024\
		-s \
		-S \
		-kernel $ESIMU_KERNEL_OUT/arch/arm64/boot/Image \
		-nographic \
		-append \"root=/dev/ram0 rw rootfstype=ramfs init=/init\" \
		-initrd $ESIMU_ROOT/out/ramdisk.img 
	"

# Start gdb
$ESIMU_TOOLCHAINS_DIR/aarch64/bin/aarch64-linux-gnu-gdb $ESIMU_KERNEL_OUT/vmlinux -x $ESIMU_SCRIPTS_DIR/debug.gdb

# Stop qemu
$ESIMU_SCRIPTS_DIR/terminate.sh
