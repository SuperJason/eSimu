echo ----------- start to run init.gdb ----------\n
target remote localhost:1234
b start_kernel
c
# Ctrol-x a to exist layout mode
layout src
