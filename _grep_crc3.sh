export LANG=C LC_ALL=C
R=/home/i/fpga-re/src/prjxray
echo "=== 位流相关文件 ==="
ls $R/prjxray/ 2>/dev/null | head -20
find $R -name "*bitstream*" -o -name "*frames2bit*" 2>/dev/null | head -10
echo "=== frames2bit 实现 ==="
for f in $(find $R -name "*frames2bit*" 2>/dev/null | head -3); do echo "--- $f"; head -40 "$f"; done
echo "=== 搜 0x30000001 / CRC 命令 ==="
grep -rn "0x30000001\|30000001" $R --include=*.py 2>/dev/null | head -5