set -u
cd /opt/lzh/v7re/work/partpair
tar czf - b0_1157/b0_1157.bit b0_1761/b0_1761.bit b0b_1157/b0b_1157.bit r_1157/r_1157.bit r_1761/r_1761.bit 2>/dev/null | base64 -w0
echo
