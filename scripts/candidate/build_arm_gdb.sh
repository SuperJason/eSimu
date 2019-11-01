#!/usr/bin/env sh
#
# Building `arm-none-eabi-gdb` with python support
# Refor to https://gist.github.com/JayKickliter/8004bafaf3d365dc8fe23843fae15c67
#

export VERSION=8.3.1
export GDB=gdb-$VERSION

export TARGET=arm-none-eabi
export PREFIX=$PWD/installed_gdb-$VERSION
export PATH=$PATH:$PREFIX/bin

rm -rf $GDB

# Get archives
#wget http://ftp.gnu.org/gnu/gdb/$GDB.tar.gz
wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gdb/$GDB.tar.gz

# Extract archives
tar xzvf $GDB.tar.gz

mkdir build-gdb
cd build-gdb
../$GDB/configure --target=$TARGET --prefix=$PREFIX --enable-interwork --enable-multilib --with-python
make -j8 
make install
