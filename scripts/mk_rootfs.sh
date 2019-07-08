#!/bin/bash
# This script is better to be run as fakeroot

if [ $(id -u) -ne 0 ]; then
	echo "#############"
	echo "### ERROR ### Current user is not root, recommaned to run this script as fakeroot!!"
	echo "#############"
	exit 1;
fi

if [  ! -n "$ESIMU_ROOT" ]; then
	ESIMU_ROOT=$(cd "$(dirname "$0")/../../";pwd)
fi

source $ESIMU_ROOT/eSimu/scripts/envsetup.sh

cd $ESIMU_ROOTFS_DIR/

rm -rf $ESIMU_ROOTFS_DIR/*
rm -rf $ESIMU_ROOT/out/ramdisk*

# install busybox
cp -raf $ESIMU_BUSYBOX_OUT/_install/* $ESIMU_ROOTFS_DIR/

# create necessary dirs
mkdir -p $ESIMU_ROOTFS_DIR/proc/
mkdir -p $ESIMU_ROOTFS_DIR/sys/
mkdir -p $ESIMU_ROOTFS_DIR/tmp/
mkdir -p $ESIMU_ROOTFS_DIR/root/
mkdir -p $ESIMU_ROOTFS_DIR/var/
mkdir -p $ESIMU_ROOTFS_DIR/mnt/
mkdir -p $ESIMU_ROOTFS_DIR/dev/

mknod $ESIMU_ROOTFS_DIR/dev/tty1 c 4 1
mknod $ESIMU_ROOTFS_DIR/dev/tty2 c 4 2
mknod $ESIMU_ROOTFS_DIR/dev/tty3 c 4 3
mknod $ESIMU_ROOTFS_DIR/dev/tty4 c 4 4
mknod $ESIMU_ROOTFS_DIR/dev/console c 5 1
mknod $ESIMU_ROOTFS_DIR/dev/null c 1 3

rm -f $ESIMU_ROOTFS_DIR/linuxrc

echo "#!/bin/busybox sh" > $ESIMU_ROOTFS_DIR/init
echo "mount -t proc none /proc" >> $ESIMU_ROOTFS_DIR/init
echo "mount -t sysfs none /sys" >> $ESIMU_ROOTFS_DIR/init
echo "" >> $ESIMU_ROOTFS_DIR/init
echo "exec /sbin/init" >> $ESIMU_ROOTFS_DIR/init
chmod a+x $ESIMU_ROOTFS_DIR/init

cd $ESIMU_ROOTFS_DIR/
find . | cpio -o -H newc | gzip -9 > $ESIMU_ROOT/out/ramdisk.gz
mkimage -n "ramdisk" -A arm -O linux -T ramdisk -C gzip -d $ESIMU_ROOT/out/ramdisk.gz $ESIMU_ROOT/out/ramdisk.img
