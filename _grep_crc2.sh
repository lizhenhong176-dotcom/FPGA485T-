export LANG=C LC_ALL=C
F=/home/i/fpga-re/src/prjxray/prjxray/bitstream.py
ls -l $F 2>/dev/null
grep -n "0x30000001\|checksum\|Checksum\|3000\|write_bit\|def serialize\|CMD\|0xAA995566" $F 2>/dev/null | head -30
echo "=== 关键函数 ==="
grep -n "def " $F 2>/dev/null | head -40