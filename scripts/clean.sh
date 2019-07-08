#!/bin/bash

if [  ! -n "$ESIMU_ROOT" ]; then
	ESIMU_ROOT=$(cd "$(dirname "$0")/../../";pwd)
fi

source $ESIMU_ROOT/eSimu/scripts/envsetup.sh

# Clear src/out dirs
rm -rf $ESIMU_ROOT/src/
rm -r $ESIMU_ROOT/out/

# Clear toolchains dirs
rm -r $ESIMU_TOOLCHAINS_DIR/

# Clear rootfs dirs, which is in out dir.

