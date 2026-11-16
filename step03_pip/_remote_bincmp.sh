set -u
export LANG=C LC_ALL=C
cd /opt/lzh/step03/band1
a=ref_B1.bit
b=ref_B1.bin
ls -l "$a" "$b"
if cmp -s -i 102:0 "$a" "$b"; then echo "MATCH: $a[102:] == $b"; else echo "DIFF: not a pure 102-byte header strip"; fi
echo "--- header hexdump ---"
od -An -tx1 -N 128 "$a"
echo "--- bin hexdump ---"
od -An -tx1 -N 64 "$b"
cd /opt/lzh/step03/tilepipe
a=ref_SLICE_X8Y11_A6LUT_A1.bit
b=ref_SLICE_X8Y11_A6LUT_A1.bin
if cmp -s -i 102:0 "$a" "$b"; then echo "MATCH: tilepipe $a[102:] == $b"; else echo "DIFF: tilepipe"; fi
