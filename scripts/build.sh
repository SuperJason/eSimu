#!/bin/bash

if [  ! -n "$ESIMU_ROOT" ]; then
	ESIMU_ROOT=$(cd "$(dirname "$0")/../../";pwd)
fi

source $ESIMU_ROOT/eSimu/scripts/envsetup.sh

function build_qemu()
{
	echo "ESIMU_QEMU_OUT: $ESIMU_QEMU_OUT"
	echo "ESIMU_QEMU_SRC: $ESIMU_QEMU_SRC"
	cd $ESIMU_QEMU_OUT
	$ESIMU_QEMU_SRC/configure --target-list=arm-softmmu,aarch64-softmmu --audio-drv-list=alsa --enable-virtfs
	make -j8 2>&1 | tee $ESIMU_ROOT/out/qemu_build.log
	cp $ESIMU_QEMU_OUT/aarch64-softmmu/qemu-system-aarch64 $ESIMU_ROOT/out/
	cp $ESIMU_QEMU_OUT/pc-bios/efi-virtio.rom $ESIMU_ROOT/out/
	echo "qemu-system-aarch64 is ready in $ESIMU_ROOT/out/"
}

function build_kernel()
{
	echo "ESIMU_KERNEL_OUT: $ESIMU_KERNEL_OUT"
	echo "ESIMU_KERNEL_SRC: $ESIMU_KERNEL_SRC"
	cd $ESIMU_KERNEL_OUT
	export CROSS_COMPILE=$ESIMU_TOOLCHAINS_DIR/aarch64/bin/aarch64-linux-gnu-
	make -C $ESIMU_KERNEL_SRC ARCH=arm64 O=$ESIMU_KERNEL_OUT Image -j8 2>&1 | tee $ESIMU_ROOT/out/kernel_build.log
}

function build_kernel_defconfig()
{
	cd $ESIMU_KERNEL_OUT
	export CROSS_COMPILE=$ESIMU_TOOLCHAINS_DIR/aarch64/bin/aarch64-linux-gnu-
	make -C $ESIMU_KERNEL_SRC ARCH=arm64 O=$ESIMU_KERNEL_OUT esimu_slim_defconfig
}

function build_kernel_menuconfig()
{
	cd $ESIMU_KERNEL_OUT
	export CROSS_COMPILE=$ESIMU_TOOLCHAINS_DIR/aarch64/bin/aarch64-linux-gnu-
	make -C $ESIMU_KERNEL_SRC ARCH=arm64 O=$ESIMU_KERNEL_OUT menuconfig
}

function build_busybox()
{
	echo "ESIMU_BUSYBOX_OUT: $ESIMU_BUSYBOX_OUT"
	echo "ESIMU_BUSYBOX_SRC: $ESIMU_BUSYBOX_SRC"
	cd $ESIMU_BUSYBOX_OUT
	export CROSS_COMPILE=$ESIMU_TOOLCHAINS_DIR/aarch64/bin/aarch64-linux-gnu-
	make KBUILD_SRC=$ESIMU_BUSYBOX_SRC -f $ESIMU_BUSYBOX_SRC/Makefile esimu_defconfig
	make -j8 2>&1 | tee $ESIMU_ROOT/out/busybox_build.log
	make install
}

function build_rootfs()
{
	fakeroot $ESIMU_SCRIPTS_DIR/mk_rootfs.sh
}

function build_debug()
{
	case $2 in
		kb)
			echo "-------------------- Kernel build --------------------"
			build_kernel
			;;
		kc)
			echo "-------------------- Kernel defConfig --------------------"
			build_kernel_defconfig
			;;
		ksc)
			echo "-------------------- Kernel SavedefConfig --------------------"
			$ESIMU_ROOT/out/
			CROSS_COMPILE=$ESIMU_TOOLCHAINS_DIR/aarch64/bin/aarch64-linux-gnu-
			make -C $ESIMU_KERNEL_SRC ARCH=arm64 O=$ESIMU_KERNEL_OUT savedefconfig
			;;
		km)
			echo "-------------------- Kernel Menuconfig --------------------"
			build_kernel_menuconfig
			;;
		*)
			echo "Usage: $name [kb|kc|ksc|km]"
			exit 0;
			;;
	esac
}

function exec_build()
{
	local name=$(basename $0)
	local start_time=$(date +"%s")
	case $1 in
		q|qemu)
			echo "-------------------- Start to build Qemu --------------------"
			build_qemu
			;;
		u|uboot)
			echo "-------------------- Start to build Uboot --------------------"
			;;
		k|kenrel)
			echo "-------------------- Start to build Kernel --------------------"
			build_kernel_defconfig
			build_kernel
			;;
		b|busybox)
			echo "-------------------- Start to build Busybox --------------------"
			build_busybox
			;;
		r|rootfs)
			echo "-------------------- Start to create Rootfs --------------------"
			build_rootfs
			;;
		d|debug)
			echo "-------------------- Start to debug --------------------"
			build_debug $*
			;;
		a|all)
			echo "-------------------- Start to build Qemu --------------------"
			build_qemu
			echo "-------------------- Start to build Uboot --------------------"
			echo "-------------------- Start to build Kernel --------------------"
			build_kernel_defconfig
			build_kernel
			echo "-------------------- Start to build Busybox --------------------"
			build_busybox
			echo "-------------------- Start to create Rootfs --------------------"
			build_rootfs
			;;
		*)
			echo "Usage: $name [all|qemu|uboot|kenrel|busybox|rootfs]"
			exit 0;
			;;
	esac

	local end_time=$(date +"%s")
	local tdiff=$(($end_time-$start_time))
	local hours=$(($tdiff / 3600 ))
	local mins=$((($tdiff % 3600) / 60))
	local secs=$(($tdiff % 60))
	echo
	echo -n -e "#### build finished "
	if [ $hours -gt 0 ] ; then
		printf "(%02g:%02g:%02g (hh:mm:ss))" $hours $mins $secs
	elif [ $mins -gt 0 ] ; then
		printf "(%02g:%02g (mm:ss))" $mins $secs
	elif [ $secs -gt 0 ] ; then
		printf "(%s seconds)" $secs
	fi
	echo -e " ####"
	echo
}

exec_build $*

