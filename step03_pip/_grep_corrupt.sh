#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
echo "== which libs contain the corrupt message =="
for f in "$V"/lib/lnx64.o/librdi_common.so "$V"/lib/lnx64.o/librdi_device.so "$V"/lib/lnx64.o/librdiconfig.so "$V"/lib/lnx64.o/libisl_iostreams.so; do
  [ -f "$f" ] || continue
  if grep -qa "is corrupt" "$f"; then echo "HIT $f"; else echo "no  $f"; fi
done
echo "== broader grep (may take a bit) =="
grep -rla "is corrupt. Please re-install" "$V/lib/lnx64.o" 2>/dev/null | head -5
