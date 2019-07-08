#!/bin/bash

QEMU_AARCH64_PID=$(ps aux | grep qemu-system-aarch64 | grep -v grep| awk '{print $2}')
QEMU_ARM_PID=$(ps aux | grep qemu-system-arm | grep -v grep| awk '{print $2}')

#echo "QEMU_AARCH64_PID=$QEMU_AARCH64_PID"
#echo "QEMU_ARM_PID=$QEMU_ARM_PID"

if [ -n "$QEMU_AARCH64_PID" ]; then
	kill $QEMU_AARCH64_PID
	echo "Qemu aarch64 process $QEMU_AARCH64_PID is killed!"
elif [ -n "$QEMU_ARM_PID" ]; then
	kill $QEMU_ARM_PID
	echo "Qemu arm process $QEMU_ARM_PID is killed!"
else
	echo "Nether qemu-system-aarch64 nor qemu-system-arm process!"
fi
