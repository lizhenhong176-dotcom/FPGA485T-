#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
echo "== lib/lnx64.o: Bs / bit / impl =="
ls -l "$V/lib/lnx64.o" | grep -Ei 'libbs|bit|impl|route|place' | head -30
echo "== ids_lite virtex7 lib =="
ls -l "$V/ids_lite/ISE/virtex7/lib/lin64" 2>/dev/null | head -20
echo "== libBsFuji size =="
ls -l "$V/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitgen.so" 2>/dev/null
