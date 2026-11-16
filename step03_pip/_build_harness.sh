#!/bin/bash
set +e
D=/mnt/c/Users/S.tschai/bitrev
mkdir -p "$D"
cd "$D" || exit 1
g++ -O2 -o crc_harness crc_harness.cpp -ldl 2>&1 | head -20
echo "RC=$?"
ls -l crc_harness 2>/dev/null
./crc_harness 2>&1 | head -45
