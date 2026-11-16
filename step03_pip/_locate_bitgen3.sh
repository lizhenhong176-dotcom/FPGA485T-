#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
echo "== name contains bitgen =="
find "$V" -iname '*bitgen*' 2>/dev/null | head -20
echo "== grep bitgen in bin =="
grep -rIl 'bitgen' "$V/bin" 2>/dev/null | head -10
echo "== lib dirs =="
ls -d "$V"/lib/* 2>/dev/null | head -10
echo "== big binaries >5MB under bin/lib =="
find "$V/bin" "$V/lib" -maxdepth 3 -type f -size +5M 2>/dev/null | head -30
