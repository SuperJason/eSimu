#!/bin/bash

if [  ! -n "$ESIMU_ROOT" ]; then
	ESIMU_ROOT=$(cd "$(dirname "$0")/../../";pwd)
fi

echo "-------------------- start to setup environment --------------------"
echo "ESIMU_ROOT: $ESIMU_ROOT"
source $ESIMU_ROOT/eSimu/scripts/envsetup.sh

ESIMU_AARCH64_TOOLCHAINS_TARBALL=gcc-linaro-6.2.1-2016.11-x86_64_aarch64-linux-gnu.tar.xz 
ESIMU_AARCH32_TOOLCHAINS_TARBALL=gcc-linaro-6.2.1-2016.11-x86_64_arm-linux-gnueabihf.tar.xz

# Clear src/out dirs
rm -rf $ESIMU_ROOT/src/*
rm -rf $ESIMU_ROOT/out/*

if [ ! -f "$ESIMU_TARBALLS_DIR/qemu-4.0.0.tar.xz" ]; then
	if [ -f "$ESIMU_TARBALLS_DIR/tarballs.tar.bz200" ]; then
		echo "Tarballs preparing..."
		cd $ESIMU_TARBALLS_DIR/
		cat tarballs.tar.bz2* | tar -xjf -
		#rm -r tarballs.tar.bz2*
		# These splitted bz2 files are created with the following command:
		#   tar -cjvf - * | split -b 48M -d - tarballs.tar.bz2
	else
		echo "### ERROR ### tarballs.tar.bz2* are not exist!"
		exit 1;
	fi
fi

cd $ESIMU_ROOT

# Create toolchains dirs
if [ ! -d "$ESIMU_TOOLCHAINS_DIR/aarch64" ]; then
	mkdir -p $ESIMU_TOOLCHAINS_DIR/aarch64
fi
if [ ! -d "$ESIMU_TOOLCHAINS_DIR/aarch32" ]; then
	mkdir -p $ESIMU_TOOLCHAINS_DIR/aarch32
fi

# Create src dirs
mkdir -p $ESIMU_QEMU_SRC
mkdir -p $ESIMU_UBOOT_SRC
mkdir -p $ESIMU_KERNEL_SRC
mkdir -p $ESIMU_BUSYBOX_SRC

# Create out dirs
mkdir -p $ESIMU_QEMU_OUT
mkdir -p $ESIMU_UBOOT_OUT
mkdir -p $ESIMU_KERNEL_OUT
mkdir -p $ESIMU_BUSYBOX_OUT

mkdir -p $ESIMU_ROOTFS_DIR

echo "Toolchains preparing..."
if [ -z "$(ls -A $ESIMU_TOOLCHAINS_DIR/aarch64)" ]; then
	echo "  aarch64..."
	tar xf $ESIMU_TARBALLS_DIR/$ESIMU_AARCH64_TOOLCHAINS_TARBALL -C $ESIMU_TOOLCHAINS_DIR/aarch64 --strip-components=1
fi
if [ -z "$(ls -A $ESIMU_TOOLCHAINS_DIR/aarch32)" ]; then
	echo "  aarch32..."
	tar xf $ESIMU_TARBALLS_DIR/$ESIMU_AARCH32_TOOLCHAINS_TARBALL -C $ESIMU_TOOLCHAINS_DIR/aarch32 --strip-components=1
fi

echo "Qemu source code preparing..."
ESIMU_TARBALL=qemu-4.0.0.tar.xz
ESIMU_SRC_PATH=$ESIMU_QEMU_SRC
tar xf $ESIMU_TARBALLS_DIR/$ESIMU_TARBALL -C $ESIMU_SRC_PATH --strip-components=1
cd $ESIMU_SRC_PATH
git init 
git add -A .
git commit -qm "Initial git repository with $ESIMU_TARBALL"
ESIMU_PATCHES_CUR_DIR=$ESIMU_PATCHES_DIR/qemu
if [[ -d $ESIMU_PATCHES_CUR_DIR && -n "$(ls -A $ESIMU_PATCHES_CUR_DIR)" ]]; then
	git am $ESIMU_PATCHES_CUR_DIR/*
fi
cd $ESIMU_ROOT 

echo "Uboot source code preparing..."
ESIMU_TARBALL=u-boot-2019.04.tar.bz2
ESIMU_SRC_PATH=$ESIMU_UBOOT_SRC
tar xjf $ESIMU_TARBALLS_DIR/$ESIMU_TARBALL -C $ESIMU_SRC_PATH --strip-components=1
cd $ESIMU_SRC_PATH
git init 
git add -A .
git commit -qm "Initial git repository with $ESIMU_TARBALL"
ESIMU_PATCHES_CUR_DIR=$ESIMU_PATCHES_DIR/uboot
if [[ -d $ESIMU_PATCHES_CUR_DIR && -n "$(ls -A $ESIMU_PATCHES_CUR_DIR)" ]]; then
	git am $ESIMU_PATCHES_CUR_DIR/*
fi
cd $ESIMU_ROOT

echo "Linux kernel source code preparing..."
ESIMU_TARBALL=linux-5.1.15.tar.xz
ESIMU_SRC_PATH=$ESIMU_KERNEL_SRC
tar xf $ESIMU_TARBALLS_DIR/$ESIMU_TARBALL -C $ESIMU_SRC_PATH --strip-components=1
cd $ESIMU_SRC_PATH
git init 
git add -A .
git commit -qm "Initial git repository with $ESIMU_TARBALL"
ESIMU_PATCHES_CUR_DIR=$ESIMU_PATCHES_DIR/kernel
if [[ -d $ESIMU_PATCHES_CUR_DIR && -n "$(ls -A $ESIMU_PATCHES_CUR_DIR)" ]]; then
	git am $ESIMU_PATCHES_CUR_DIR/*
fi
cd $ESIMU_ROOT

echo "Busybox source code preparing..."
ESIMU_TARBALL=busybox-1.31.0.tar.bz2
ESIMU_SRC_PATH=$ESIMU_BUSYBOX_SRC
tar xjf $ESIMU_TARBALLS_DIR/$ESIMU_TARBALL -C $ESIMU_SRC_PATH --strip-components=1
cd $ESIMU_SRC_PATH
git init 
git add -A .
git commit -qm "Initial git repository with $ESIMU_TARBALL"
ESIMU_PATCHES_CUR_DIR=$ESIMU_PATCHES_DIR/busybox
if [[ -d $ESIMU_PATCHES_CUR_DIR && -n "$(ls -A $ESIMU_PATCHES_CUR_DIR)" ]]; then
	git am $ESIMU_PATCHES_CUR_DIR/*
fi
cd $ESIMU_ROOT

cd $ESIMU_ROOT/out/
