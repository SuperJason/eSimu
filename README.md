This is a simple Embedded ARM Linux simulator environment for study.

By default, the source code versions:
* Qemu: qemu-4.0.0
* Uboot: u-boot-2019.04
* Linux Kernel: linux-5.1.15
* Busybox: busybox-1.31.0
* Toolchans: gcc-linaro-6.2.1-2016.11

## Installing Dependencies
Install dependencies required for building on Debian-based Linux distributions:
```
apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache u-boot-tools
```

## Soure Code Environment Prepare
```
scripts/setup.sh
```

## Building
```
scripts/build.sh all
```

## Run simulator
Run aarch64 qemu simulator generally.
```
scripts/general_run.sh
```
Run aarch64 qemu simulator with gdb to debug kernel.
```
scripts/gdb_run.sh
```

