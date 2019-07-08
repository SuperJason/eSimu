#!/bin/bash

if [  ! -n "$ESIMU_ROOT" ]; then
	ESIMU_ROOT=$(cd "$(dirname "$0")/../../";pwd)
fi

source $ESIMU_ROOT/eSimu/scripts/envsetup.sh

cd $ESIMU_ROOT/out/

./qemu-system-aarch64 \
	-M virt \
	-cpu cortex-a53 \
	-m 1024\
	-s \
	-kernel $ESIMU_KERNEL_OUT/arch/arm64/boot/Image \
	-nographic \
	-append "root=/dev/ram0 rw rootfstype=ramfs init=/init" \
	-initrd $ESIMU_ROOT/out/ramdisk.img 
	
